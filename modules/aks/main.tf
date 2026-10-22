resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free"
  tags                = var.tags

  default_node_pool {
    name                        = "system"
    vm_size                     = var.node_vm_size
    vnet_subnet_id              = var.aks_subnet_id
    auto_scaling_enabled        = true
    min_count                   = var.node_min_count
    max_count                   = var.node_max_count
    node_count                  = var.node_min_count
    temporary_name_for_rotation = "systemtmp"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = "standard"
  }

  node_provisioning_profile {
    mode               = "Manual"
    default_node_pools = "Auto"
  }

  # Container Insights
  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  # AGIC add-on, pointing at the existing App Gateway
  ingress_application_gateway {
    gateway_id = var.appgw_id
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# ---------------- Role assignments ----------------
locals {
  agic_object_id = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_subnet_network" {
  scope                            = var.aks_subnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_kubernetes_cluster.this.identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "agic_appgw" {
  scope                            = var.appgw_id
  role_definition_name             = "Contributor"
  principal_id                     = local.agic_object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "agic_rg_reader" {
  scope                            = var.resource_group_id
  role_definition_name             = "Reader"
  principal_id                     = local.agic_object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "agic_appgw_subnet" {
  scope                            = var.appgw_subnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = local.agic_object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
