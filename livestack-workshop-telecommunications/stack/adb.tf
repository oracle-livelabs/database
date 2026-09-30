#*************************************
#           Source ATP
#*************************************

resource  oci_database_autonomous_database source_autonomous_database  {
  #Required
  admin_password = local.new_password
  compartment_id =  var.ociCompartmentOcid
  compute_model = "ECPU"
  compute_count = 2
  data_storage_size_in_tbs = 1
  db_name   = "ATP${var.resId}"
  db_tools_details {
    #Required
    name = "MONGODB_API"
    #Optional
    is_enabled = true
    }
  db_version = "26ai"
  display_name   = "AIATP${var.resId}"
  license_model = "BRING_YOUR_OWN_LICENSE"
  db_workload = "OLTP"
  is_free_tier = false
  is_mtls_connection_required = false
  whitelisted_ips = ["0.0.0.0/0"]
}


data "oci_database_autonomous_database" "source_autonomous_database" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.source_autonomous_database.id
}

resource "oci_database_autonomous_database_wallet" "source_autonomous_database_wallet" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.source_autonomous_database.id
    password = local.new_password

    #Optional
    base64_encode_content = "true"
    generate_type = "SINGLE"
}

resource "local_file" "source_autonomous_database_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.source_autonomous_database_wallet.content
  filename       = "atp_wallet.zip"
}


resource "local_file" "create_user" {
  depends_on      = [local_file.source_autonomous_database_wallet_file]
  filename        = "${path.module}/create_user.sql"  
  file_permission = "0600"
  content = templatefile("${path.module}/create_user.sql.tmpl", {
    user_password     = local.new_password
  })
}


resource "null_resource" "sqlcl-load-data-atp" {
    provisioner "local-exec" {
        command = "sql -cloudconfig atp_wallet.zip admin/${local.new_password}@ATP${var.resId}_high @${local_file.create_user.filename}"
    }
    depends_on = [
        local_file.create_user
	]
}

resource "null_resource" "sqlcl-load-data-atp2" {
    provisioner "local-exec" {
        command = "sql -cloudconfig atp_wallet.zip lluser/${local.new_password}@ATP${var.resId}_high @${local_file.genai_connection.filename}"
    }
    depends_on = [
        null_resource.sqlcl-load-data-atp
	]
}

resource "null_resource" "sqlcl-load-data-atp3" {
    provisioner "local-exec" {
        working_dir = path.module
        command = "sql -cloudconfig atp_wallet.zip admin/${local.new_password}@ATP${var.resId}_high @load_data/telecommunications-platform-handoff-loader.sql ${local.new_password} ATP${var.resId}_high"
    }
    depends_on = [
        null_resource.sqlcl-load-data-atp2
	]
}
