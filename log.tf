# ---------------- Monitoring ----------------
resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-${var.prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ---------------- Container Registry ----------------
resource "azurerm_container_registry" "lab" {
  name                = local.acr_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}