output "bucket_name" {
  value = oci_objectstorage_bucket.tofu_state.name
}

output "namespace" {
  value = data.oci_objectstorage_namespace.ns.namespace
}