terraform {
  required_providers {  
    azurerm = {        
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_resource_group" "test_grp" {
  name     =  azurerm_resource_group.app_grp.name
  location = "East US"
}



