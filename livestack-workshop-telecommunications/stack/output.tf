output "sql_url" {
  value =    [  oci_database_autonomous_database.source_autonomous_database.connection_urls[0].sql_dev_web_url]
}

output "atp_ml_password" {
  value = local.new_password
  sensitive = true
}

output "atp_ml_user" {
  value = "LLUSER"
}