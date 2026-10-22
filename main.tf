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

# ---------------- Network ----------------
module "network" {
  source = "./modules/network"

  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  vnet_cidr           = var.vnet_cidr
  aks_subnet_cidr     = var.aks_subnet_cidr
  appgw_subnet_cidr   = var.appgw_subnet_cidr
  tags                = var.tags
}

# ---------------- Monitoring ----------------
module "monitoring" {
  source = "./modules/monitoring"

  name                = "law-${var.prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ---------------- Container Registry ----------------
module "acr" {
  source = "./modules/acr"

  name                = local.acr_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

# ---------------- App Gateway + WAF ----------------
module "appgw" {
  source = "./modules/appgw"

  name                       = local.appgw_name
  waf_policy_name            = "wafp-${var.prefix}"
  public_ip_name             = "pip-agw-${var.prefix}"
  location                   = azurerm_resource_group.lab.location
  resource_group_name        = azurerm_resource_group.lab.name
  subnet_id                  = module.network.appgw_subnet_id
  capacity                   = var.appgw_capacity
  waf_mode                   = var.waf_mode
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                       = var.tags
}

# ---------------- AKS ----------------
module "aks" {
  source = "./modules/aks"

  name                = local.aks_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  resource_group_id   = azurerm_resource_group.lab.id
  kubernetes_version  = var.kubernetes_version

  node_vm_size   = var.node_vm_size
  node_min_count = var.node_min_count
  node_max_count = var.node_max_count

  aks_subnet_id  = module.network.aks_subnet_id
  service_cidr   = var.service_cidr
  dns_service_ip = var.dns_service_ip

  log_analytics_workspace_id = module.monitoring.workspace_id
  appgw_id                   = module.appgw.id
  appgw_subnet_id            = module.network.appgw_subnet_id
  acr_id                     = module.acr.id

  tags = var.tags
}

# ---------------- DNS (optional) ----------------
module "dns" {
  source = "./modules/dns"
  count  = var.use_azure_dns ? 1 : 0

  zone_name           = var.dns_zone
  record_name         = var.app_subdomain
  resource_group_name = azurerm_resource_group.lab.name
  target_resource_id  = module.appgw.public_ip_id
  tags                = var.tags
}
