variable "tenancy_ocid" {
  type        = string
  description = "The tenancy OCID"
}

variable "user_ocid" {
  type        = string
  description = "The user OCID"
}

variable "fingerprint" {
  type        = string
  description = "The key fingerprint"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key"
}

variable "region" {
  type        = string
  description = "The OCI region"
}

variable "compartment_ocid" {
  type        = string
  description = "The compartment OCID where resources will be created"
}

variable "vcn_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VCN"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR block for the public subnet"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for the compute instance"
}