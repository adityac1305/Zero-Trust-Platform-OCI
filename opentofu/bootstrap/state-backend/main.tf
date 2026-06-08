terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

#################################################
# OBJECT STORAGE NAMESPACE
#################################################

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

#################################################
# STATE BUCKET
#################################################

resource "oci_objectstorage_bucket" "tofu_state" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace

  name = var.bucket_name

  access_type = "NoPublicAccess"

  storage_tier = "Standard"

  versioning = "Enabled"
}