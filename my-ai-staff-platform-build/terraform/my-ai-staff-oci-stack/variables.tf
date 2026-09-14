variable "tenancy_ocid" {
  description = "Tenancy OCID. Required to create the bootstrap instance dynamic group and policy."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment in which to create the workshop resources."
  type        = string
}

variable "region" {
  description = "OCI region for the stack."
  type        = string
}

variable "ssh_public_key" {
  description = "OpenSSH public key allowed to connect as opc."
  type        = string
}

variable "admin_cidr" {
  description = "CIDR allowed to use SSH, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 or IPv6 CIDR block."
  }
}

variable "adb_admin_password" {
  description = "ADMIN password for Autonomous Database."
  type        = string
  sensitive   = true
}

variable "wallet_password" {
  description = "Password used to encrypt the downloaded Autonomous Database wallet."
  type        = string
  sensitive   = true
}

variable "ai_for_you_password" {
  description = "Password for the AI_FOR_YOU application schema."
  type        = string
  sensitive   = true
}

variable "availability_domain" {
  description = "Optional availability domain name. Leave null to use the first available AD."
  type        = string
  default     = null
}

variable "adb_db_version" {
  description = "Autonomous AI Database version offered in the selected region."
  type        = string
  default     = "26ai"
}

variable "platform_zip_url" {
  description = "Versioned public URL for the My AI Staff platform ZIP."
  type        = string
  default     = "https://c4u02.objectstorage.us-ashburn-1.oci.customer-oci.com/p/9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3/n/c4u02/b/hosted-files/o/livelabs-ai-staff.zip"
}

variable "model_url" {
  description = "Pinned public Oracle URL for the augmented all-MiniLM-L12-v2 ONNX model."
  type        = string
  default     = "https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/iPX9W0MZeRkwJKWdFmdJCemmN-iKAl_bFvNGYLW7YqIrw4kKsukL24J2q93Beb9S/n/adwc4pm/b/OML-ai-models/o/all_MiniLM_L12_v2.onnx"
}

variable "model_sha256" {
  description = "SHA-256 of the ONNX bytes downloaded from model_url."
  type        = string
  default     = "3929907d138051f818619fce3ba054185f748f2739d7a4dbc26e2502dd2499ea"

  validation {
    condition     = can(regex("^[0-9a-f]{64}$", var.model_sha256))
    error_message = "model_sha256 must be a lowercase SHA-256 digest."
  }
}

variable "resource_prefix" {
  description = "Short prefix used in resource display names."
  type        = string
  default     = "my-ai-staff"
}
