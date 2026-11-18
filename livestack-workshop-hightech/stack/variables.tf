/*
********************
# Copyright (c) 2025 Oracle and/or its affiliates. All rights reserved.
# by - Rene Fontcha - Oracle LiveLabs Platform Lead
# Last Updated - 11/01/2022
********************
*/

variable "ociTenancyOcid" { default = "" }
variable "ociUserOcid" { default = "" }
variable "ociCompartmentOcid" { default = "" }
variable "ociUserPassword" { default = "" }
variable "ociRegionIdentifier" { default = "" }
variable "resId" { default = "" }
variable "ociPrivateSubnetOcid" { default = "" }
variable "ociPublicSubnetOcid" { default = "" }
variable "ociVcnOcid" { default = "" }
variable "resUserPublicKey" { default = "" }
variable "ociGenAiRegion" {
  description = "OCI Generative AI inference region, independent of the database region."
  default     = "us-chicago-1"
}

variable "ociGenAiModel" {
  description = "On-demand model available in the selected inference region."
  default     = "cohere.command-a-03-2025"
}


#*****************************************
#             Random Password
#*****************************************
resource "random_string" "password" {
  length  = 16
  special = false
  lower   = true
  upper   = true
  numeric = true
  #min_special = 2
  min_numeric = 2
  min_lower   = 2
  min_upper   = 2
  #override_special = "#"
}

resource "random_string" "vncpwd" {
  length  = 10
  upper   = true
  lower   = true
  numeric = true
  special = false
}

#*************************************
#        Local Variables
#*************************************
locals {
  timestamp = formatdate("YYYY-MM-DD-hhmmss", timestamp())
}

resource "random_string" "first_char" {
  length  = 1
  special = false
  lower   = true
  upper   = true
  numeric = false # Ensures it starts with a letter
}

# Remaining characters
resource "random_string" "rest_of_password" {
  length      = 15
  special     = false
  lower       = true
  upper       = true
  numeric     = true
  min_numeric = 2
  min_lower   = 2
  min_upper   = 2
}

locals {
  new_password = "${random_string.first_char.result}${random_string.rest_of_password.result}"
}
