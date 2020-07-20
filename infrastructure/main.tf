variable "subscription_id" {
  description = "Subscription ID"
  default = ""
}

variable "client_id" {
    description = "Client ID"
    default = ""
}

variable "client_secret" {
    description = "Client secret"
    default = ""
}

variable "tenant_id" {
    description = "Tenant ID"
    default = ""
}

# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
  version = "~>2.5"
}

locals{
  resource_group_name         = "Avid-SIG-RG"
  location                    = "eastus2"
  shared_image_gallery_name   = "Avid_SIG"
  shared_tags                 = {
                                  "environment" = "development"
                                }
}

resource "azurerm_resource_group" "avid-shared-images" {
    name        =  local.resource_group_name
    location    = local.location
    tags        = local.shared_tags
}

resource "azurerm_shared_image_gallery" "avid-shared-images" {
    name                = local.shared_image_gallery_name
    resource_group_name = azurerm_resource_group.avid-shared-images.name
    location            = azurerm_resource_group.avid-shared-images.location
    description         = "Avid Shared Images."
    tags                = local.shared_tags
}

resource "azurerm_shared_image" "shared-images-MediaCentral" {
  name                = "MediaCentral"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Linux"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "MediaCentral"
  }
}

resource "azurerm_shared_image" "shared-images-MediaComposer" {
  name                = "MediaComposer"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Windows"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "MediaComposer"
  }
}

resource "azurerm_shared_image" "shared-images-MediaComposer2020" {
  name                = "MediaComposer2020"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Windows"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "MediaComposer2020"
  }
  tags = local.shared_tags
}

resource "azurerm_shared_image" "shared-images-Mediaworker" {
  name                = "MediaWorker"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Windows"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "MediaWorker"
  }
}

resource "azurerm_shared_image" "shared-images-Nexis-Cloud-Online" {
  name                = "Nexis_Cloud_Online"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Linux"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "Nexis_Cloud_Online"
  }
}

resource "azurerm_shared_image" "shared-images-Nexis-Nearline" {
  name                = "Nexis_Nearline"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Linux"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "Nexis_Nearline"
  }
}

resource "azurerm_shared_image" "shared-images-Jumpbox" {
  name                = "Jumpbox"
  gallery_name        = azurerm_shared_image_gallery.avid-shared-images.name
  resource_group_name = azurerm_resource_group.avid-shared-images.name
  location            = azurerm_resource_group.avid-shared-images.location
  os_type             = "Windows"

  identifier {
    publisher = "AvidECD"
    offer     = "EditorialInTheCloud"
    sku       = "Jumpbox"
  }
}