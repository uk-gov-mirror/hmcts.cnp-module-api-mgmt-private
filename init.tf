terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.0"
    }
  }
}

locals {
  name = var.custom_name != null ? var.custom_name : "${var.department}-api-mgmt-${local.environment}"
  # platform_api_mgmt_sku = var.environment == "prod" ? "Premium_1" : "Developer_1"

  environment = (var.environment == "aat") ? "stg" : (var.environment == "sandbox") ? "sbox" : "${(var.environment == "perftest") ? "test" : "${var.environment}"}"

  acme_environment = (var.environment == "aat") ? "stg" : (var.environment == "sandbox") ? "sbox" : (var.environment == "preview") ? "dev" : "${(var.environment == "perftest") ? "test" : "${var.environment}"}"

  department = var.department == "sds" ? "dtssds" : (var.department == "sps" ? "dtssps" : "dcdcft")

  acmekv = var.department == "sds" ? "dtssds" : (var.department == "sps" ? "dtssps" : "dcdcftapps")

  sku_name = var.sku_name == "Premium" ? "Premium_3" : "Developer_1"
  zones    = var.sku_name == "Premium" ? ["1", "2", "3"] : []

  key_vault_environment = (var.environment == "sbox") ? "sandbox" : (var.environment == "stg") ? "staging" : var.environment

  cert_url = var.certificate_secret_id != null ? var.certificate_secret_id : replace(data.azurerm_key_vault_certificate.certificate[0].secret_id, "/${data.azurerm_key_vault_certificate.certificate[0].version}", "")
  criticality = {
    sbox     = "Low"
    aat      = "High"
    stg      = "High"
    prod     = "High"
    prod-int = "High"
    ithc     = "Medium"
    test     = "Medium"
    perftest = "Medium"
    demo     = "Medium"
    dev      = "Low"
    ptl      = "High"
    preview  = "Low"
    ldata    = "High"
    sandbox  = "Low"
    nle      = "High"
    nonprod  = "Medium"
    nonprodi = "Medium"
    ptlsbox  = "Low"
    sbox-int = "Low"
  }

  environment_mapping = {
    production  = ["ptl", "prod", "prod-int"]
    development = ["dev", "preview"]
    staging     = ["ldata", "stg", "aat", "nle", "nonprod", "nonprodi"]
    testing     = ["test", "perftest"]
    sandbox     = ["sandbox", "sbox", "ptlsbox", "sbox-int"]
    demo        = ["demo"]
    ithc        = ["ithc"]
  }


  acmedcdcftapps = {
    sbox = {
      subscription = "b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb"
    }
    test = {
      subscription = "8a07fdcd-6abd-48b3-ad88-ff737a4b9e3c"
    }
    dev = {
      subscription = "8b6ea922-0862-443e-af15-6056e1c9b9a4"
    }
    demo = {
      subscription = "d025fece-ce99-4df2-b7a9-b649d3ff2060"
    }
    stg = {
      subscription = "96c274ce-846d-4e48-89a7-d528432298a7"
    }
    ithc = {
      subscription = "62864d44-5da9-4ae9-89e7-0cf33942fa09"
    }
    prod = {
      subscription = "8cbc6f36-7c56-4963-9d36-739db5d00b27"
    }
  }

  acmedtssdsapps = {
    sbox = {
      subscription = "a8140a9e-f1b0-481f-a4de-09e2ee23f7ab"
    }
    dev = {
      subscription = "867a878b-cb68-4de5-9741-361ac9e178b6"
    }
    stg = {
      subscription = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
    }
    prod = {
      subscription = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
    }
    test = {
      subscription = "3eec5bde-7feb-4566-bfb6-805df6e10b90"
    }
    ithc = {
      subscription = "ba71a911-e0d6-4776-a1a6-079af1df7139"
    }
    demo = {
      subscription = "c68a4bed-4c3d-4956-af51-4ae164c1957c"
    }
  }

  acmedtsspsapps = {
    sbox = {
      subscription = "bd2864ed-4f3e-45ed-9c6a-8d179674bab1"
    }
    dev = {
      subscription = "7cfd7e05-06a1-4d9b-a426-db304bc99aab"
    }
    stg = {
      subscription = "70bea6e3-384f-4cf4-b551-743a78d716cd"
    }
    prod = {
      subscription = "890625e2-7a8b-445c-81b4-8044a062cef3"
    }
    test = {
      subscription = "4e0267c8-d18a-460b-8707-496f0b36954d"
    }
    ithc = {
      subscription = "3939bf63-a2a9-404f-a023-0d21f1f14548"
    }
    demo = {
      subscription = "058bf954-ac1f-462b-bca4-42a30314bd74"
    }
  }

  palo_environment_mapping = {
    sbox    = ["sbox"]
    nonprod = ["dev", "demo", "ithc", "test", "preview"]
    prod    = ["prod", "stg"]
  }

  palo_ip_addresses = {
    sbox = {
      addresses = "10.10.200.37,10.10.200.38"
    },
    nonprod = {
      addresses = "10.11.72.37,10.11.72.38"
    },
    prod = {
      addresses = "10.11.8.37,10.11.8.38"
    }
  }
}

provider "azurerm" {
  alias                      = "acmedcdcftapps"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.department == "sds" ? local.acmedtssdsapps[local.acme_environment].subscription : (var.department == "sps" ? local.acmedtsspsapps[local.acme_environment].subscription : local.acmedcdcftapps[local.acme_environment].subscription)
}
