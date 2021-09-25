provider "azurerm" {
  version = "~>2.0"
  features {
        subscription_id = "bf6d4b4a-2c99-4f81-af3c-4d8db3848677"
        client_id       = "acc6b888-5121-4fdc-be7f-05834dfdb646"
        client_secret   = "e-rk~Z92ME.f~Td~6CE2ihe5xK936BFun1"
        tenant_id       = "3882b70d-a91e-468c-9928-820358bfbd73"
  }
}

/*terraform {
    backend "azurerm" {
        resource_group_name = "cloud-shell-storage-centralindia"
        storage_account_name = "csg1003200161986bca"
        container_name = "tfstate"
        key = "terraform1.tfstate"
    }
}*/
/*resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}*/

# Get Resources from a Resource Group
data "azurerm_resource_group" "example" {
  name = "TF-State-RG"
  #location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "tfstraccn3876"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
