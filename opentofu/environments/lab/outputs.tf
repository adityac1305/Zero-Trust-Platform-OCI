output "instance_id" {
  value = oci_core_instance.vm.id
}

output "private_ip" {
  value = oci_core_instance.vm.private_ip
}

output "public_ip" {
  value = oci_core_public_ip.reserved_ip.ip_address
}

output "vcn_id" {
  value = oci_core_vcn.lab_vcn.id
}