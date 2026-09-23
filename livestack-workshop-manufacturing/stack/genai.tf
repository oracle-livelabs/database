# Create an API key for the user 
resource "tls_private_key" "api" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Upload the key to the LiveLabs user
resource "oci_identity_api_key" "api" {
  provider  = oci.home                 
  user_id   = var.ociUserOcid
  key_value = tls_private_key.api.public_key_pem
}

# Render the SQL from the template using the key credentials created above and the LiveLabs variabled provided
resource "local_file" "genai_connection" {
  depends_on      = [oci_identity_api_key.api]
  filename        = "${path.module}/genai_connection.sql"  
  file_permission = "0600"
  content = templatefile("${path.module}/genai_connection.sql.tmpl", {
    private_key_pem     = tls_private_key.api.private_key_pem
    fingerprint         = oci_identity_api_key.api.fingerprint
    ociUserOcid         = var.ociUserOcid
    ociTenancyOcid      = var.ociTenancyOcid
    ociCompartmentOcid  = var.ociCompartmentOcid
    ociRegionIdentifier = var.ociGenAiRegion
    ociGenAiModel       = var.ociGenAiModel
  })
}


