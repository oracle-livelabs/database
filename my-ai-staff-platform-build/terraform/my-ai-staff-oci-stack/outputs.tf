output "instance_public_ip" {
  description = "Public IP for SSH administration."
  value       = oci_core_instance.workshop.public_ip
}

output "ssh_command" {
  description = "Command to connect to the bootstrap host."
  value       = "ssh opc@${oci_core_instance.workshop.public_ip}"
}

output "autonomous_database_service_name" {
  description = "Autonomous Database service name used by the bootstrap."
  value       = oci_database_autonomous_database.workshop.db_name
}

output "bootstrap_log" {
  description = "Cloud-init bootstrap log on the instance."
  value       = "/var/log/my-ai-staff-bootstrap.log"
}
