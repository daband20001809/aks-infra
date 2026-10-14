locals {
  rg_name    = "rg-${var.prefix}-lab"
  aks_name   = "aks-${var.prefix}"
  acr_name   = "acr${var.prefix}${var.suffix}"
  appgw_name = "agw-${var.prefix}"
  app_host   = "${var.app_subdomain}.${var.dns_zone}"
}

resource "azurerm_resource_group" "lab" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}