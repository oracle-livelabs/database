data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "oracle_linux_9_aarch64" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_ocid
}

locals {
  availability_domain = coalesce(var.availability_domain, data.oci_identity_availability_domains.available.availability_domains[0].name)
  image_id            = data.oci_core_images.oracle_linux_9_aarch64.images[0].id
  bucket_name         = lower(replace("${var.resource_prefix}-${random_string.suffix.result}-models", "_", "-"))
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "oci_core_vcn" "workshop" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${var.resource_prefix}-vcn"
  dns_label      = "myaistaff"
}

resource "oci_core_internet_gateway" "workshop" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.workshop.id
  display_name   = "${var.resource_prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.workshop.id
  display_name   = "${var.resource_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.workshop.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.workshop.id
  display_name   = "${var.resource_prefix}-public-sl"

  ingress_security_rules {
    protocol = "6"
    source   = var.admin_cidr

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.workshop.id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "${var.resource_prefix}-public-subnet"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_database_autonomous_database" "workshop" {
  compartment_id = var.compartment_ocid
  db_name        = "MYAISTAFF"
  display_name   = "${var.resource_prefix}-adb"
  db_workload    = "OLTP"
  db_version     = var.adb_db_version
  is_free_tier   = true
  admin_password = var.adb_admin_password
}

resource "oci_database_autonomous_database_wallet" "workshop" {
  autonomous_database_id = oci_database_autonomous_database.workshop.id
  password               = var.wallet_password
  base64_encode_content  = true
  generate_type          = "SINGLE"
}

resource "oci_objectstorage_bucket" "models" {
  compartment_id = var.compartment_ocid
  name           = local.bucket_name
  namespace      = data.oci_objectstorage_namespace.this.namespace
  access_type    = "NoPublicAccess"
}

resource "oci_objectstorage_preauthrequest" "model_read" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.models.name
  name         = "${var.resource_prefix}-model-read"
  namespace    = data.oci_objectstorage_namespace.this.namespace
  object_name  = "all_MiniLM_L12_v2.onnx"
  time_expires = "2030-01-01T00:00:00.000Z"
}

resource "oci_core_instance" "workshop" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.resource_prefix}-host"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.public.id
    display_name     = "${var.resource_prefix}-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
      adb_admin_password  = var.adb_admin_password
      ai_for_you_password = var.ai_for_you_password
      wallet_password     = var.wallet_password
      wallet_base64       = oci_database_autonomous_database_wallet.workshop.content
      adb_service_name    = oci_database_autonomous_database.workshop.db_name
      platform_zip_url    = var.platform_zip_url
      model_url           = var.model_url
      model_sha256        = var.model_sha256
      model_bucket        = oci_objectstorage_bucket.models.name
      model_namespace     = data.oci_objectstorage_namespace.this.namespace
      model_par_url       = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.model_read.access_uri}"
    }))
  }
}

resource "oci_identity_dynamic_group" "bootstrap_instance" {
  compartment_id = var.tenancy_ocid
  name           = "${var.resource_prefix}-${random_string.suffix.result}-bootstrap"
  description    = "Allows the My AI Staff bootstrap host to upload its verified ONNX model."
  matching_rule  = "ALL {instance.id = '${oci_core_instance.workshop.id}'}"
}

resource "oci_identity_policy" "bootstrap_instance" {
  compartment_id = var.tenancy_ocid
  name           = "${var.resource_prefix}-${random_string.suffix.result}-bootstrap"
  description    = "Allows only the bootstrap dynamic group to upload the verified ONNX model."
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.bootstrap_instance.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${oci_objectstorage_bucket.models.name}'"
  ]
}
