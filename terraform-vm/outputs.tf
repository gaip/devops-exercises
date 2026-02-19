# ============================================================
# Outputs: What Terraform tells you AFTER it creates everything
# ============================================================
# Same as: the JSON output from "az vm create"
# ============================================================

output "public_ip_address" {
  description = "The public IP to SSH into the VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
  description = "Copy-paste this to connect"
  value       = "ssh azureuser@${azurerm_public_ip.pip.ip_address}"
}

output "resource_group" {
  description = "The resource group name"
  value       = azurerm_resource_group.rg.name
}
