############################################
# AVAILABILITY DOMAINS
############################################
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

############################################
# UBUNTU IMAGE (ARM64)
############################################
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"

  sort_by    = "TIMECREATED"
  sort_order = "DESC"

  filter {
    name   = "display_name"
    values = [".*aarch64.*"]
    regex  = true
  }
}

############################################
# VCN
############################################
resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr

  display_name = "adityac1305-vcn"
  dns_label    = "labvcn"
}

############################################
# INTERNET GATEWAY
############################################
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id

  display_name = "adityac1305-igw"
  enabled      = true
}

############################################
# ROUTE TABLE
############################################
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id

  display_name = "adityac1305-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

############################################
# UPDATE DEFAULT SECURITY LIST
############################################
resource "oci_core_default_security_list" "default_sl" {
  manage_default_resource_id = oci_core_vcn.lab_vcn.default_security_list_id

  ##########################################
  # INGRESS RULES
  ##########################################

  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # ICMP - Path MTU Discovery
  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  # ICMP - Internal Destination Unreachable
  ingress_security_rules {
    protocol = "1"
    source   = var.vcn_cidr

    icmp_options {
      type = 3
    }
  }

  ##########################################
  # EGRESS RULES
  ##########################################
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

############################################
# PUBLIC SUBNET
############################################

resource "oci_core_subnet" "public_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id

  cidr_block   = var.subnet_cidr
  display_name = "adityac1305-public-subnet"

  route_table_id = oci_core_route_table.rt.id

  # Use DEFAULT security list
  security_list_ids = [
    oci_core_vcn.lab_vcn.default_security_list_id
  ]

  prohibit_public_ip_on_vnic = false
}

############################################
# COMPUTE INSTANCE
############################################
resource "oci_core_instance" "vm" {
  compartment_id = var.compartment_ocid

  # Try AD-1 first
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  display_name = "adityac1305-lab"

  shape = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
    #boot_volume_size_in_gbs = 50   # Clean 50 GB partition allocation for OS root
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

############################################
# ADDITIONAL 140 GB DATA BLOCK VOLUME
############################################
resource "oci_core_volume" "lab_data_volume" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "adityac1305-lab-data"
  size_in_gbs         = 140
}

############################################
# ATTACH DATA VOLUME TO COMPUTE VM
############################################
resource "oci_core_volume_attachment" "lab_volume_attach" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm.id
  volume_id       = oci_core_volume.lab_data_volume.id
}

############################################
# VNIC ATTACHMENTS
############################################
data "oci_core_vnic_attachments" "vm_vnic_attach" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.vm.id

  depends_on = [
    oci_core_instance.vm
  ]
}

############################################
# PRIVATE IP LOOKUP
############################################
data "oci_core_private_ips" "vm_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.vm_vnic_attach.vnic_attachments[0].vnic_id

  depends_on = [
    data.oci_core_vnic_attachments.vm_vnic_attach
  ]
}

############################################
# RESERVED PUBLIC IP
############################################
resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_ocid

  display_name = "adityac1305-lab-reserved-ip"

  lifetime      = "RESERVED"
  private_ip_id = data.oci_core_private_ips.vm_private_ips.private_ips[0].id
}