output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "aks_name" {
  value = module.aks.name
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "appgw_public_ip" {
  value = module.appgw.public_ip_address
}

output "app_url" {
  value = "http://${local.app_host}"
}

output "dns_name_servers" {
  description = "Point your registrar's NS records here (only when use_azure_dns = true)"
  value       = var.use_azure_dns ? module.dns[0].name_servers : []
}

output "get_credentials_cmd" {
  value = "az aks get-credentials -g ${azurerm_resource_group.lab.name} -n ${module.aks.name}"
}
