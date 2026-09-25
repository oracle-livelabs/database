terraform {
  required_version = ">= 0.12.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.5.0"
    }
  }
}

variable "home-tenancy" {
  type = map(any)
  default = {
    //C4u04
    "ocid1.tenancy.oc1..aaaaaaaawunzd6xr55ka46cpbrck6ndreki5banncuynudejkajqhqsvdbza" = "us-ashburn-1"
    //c4u02
    "ocid1.tenancy.oc1..aaaaaaaa4jbkwc4jal7ydsvwohnrrq6hyxb2thgqazxv43olgwyboav5defq" = "us-ashburn-1"
    //c4ustudent03
    "ocid1.tenancy.oc1..aaaaaaaaqk2xnbkaaiuccul2i3rhws3lw2qpjw3d2we2kzpwpxjit74npaza" = "us-ashburn-1"
    //devrel
    "ocid1.tenancy.oc1..aaaaaaaayz6bptazeg7qiqy4rt4k3otxi5umailp3rzeio6cc3ubub2n26ia" = "us-phoenix-1"
    // selivelabs
    "ocid1.tenancy.oc1..aaaaaaaaxhgnthgy64eo2o5xrriepvcnt65nmsuwzzrhfikv7dtbzdq6a7rq" = "us-ashburn-1"
    //testdrives
    "ocid1.tenancy.oc1..aaaaaaaakut3kzsjctngo6lab62ca5kfx3ycesyxxf3o7vlmihu2gzstf75a" = "us-ashburn-1"
    //lldev
    "ocid1.tenancy.oc1..aaaaaaaasaqdiqj3hdnmn4z3qyg6t6lfbsgex2txnum5k5ujjjsfdu7xjdvq" = "us-ashburn-1"
  }
}

provider "oci" {
  region = var.ociRegionIdentifier
  //region           =  var.home-tenancy[var.ociTenancyOcid]
}

provider "oci" {
  alias = "home"
  //  region           = "us-ashburn-1"
  region = var.home-tenancy[var.ociTenancyOcid]
}

provider "oci" {
  alias  = "main"
  region = var.ociRegionIdentifier
}
