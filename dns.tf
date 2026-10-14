resource "azurerm_dns_zone" "lab" {
  count               = var.use_azure_dns ? 1 : 0
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

resource "azurerm_dns_a_record" "app" {
  count               = var.use_azure_dns ? 1 : 0
  name                = var.app_subdomain
  zone_name           = azurerm_dns_zone.lab[0].name
  resource_group_name = azurerm_resource_group.lab.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.appgw.id
}
