# ---------------- WAF policy ----------------
resource "azurerm_web_application_firewall_policy" "this" {
  name                = var.waf_policy_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  custom_rules {
    name      = "BlockLabHeader"
    priority  = 10
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "x-lab-block"
      }
      operator           = "Equal"
      negation_condition = false
      match_values       = ["true"]
      transforms         = ["Lowercase"]
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"
    }
  }
}

# ---------------- Public IP ----------------
resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

# ---------------- Application Gateway ----------------
# Listener/pool/rule below are placeholders; AGIC manages them at runtime,
# hence the ignore_changes block.
locals {
  agw_feip     = "appGatewayFrontendIP"
  agw_port_80  = "port_80"
  agw_pool     = "defaultaddresspool"
  agw_settings = "defaulthttpsetting"
  agw_listener = "defaulthttplistener"
  agw_rule     = "defaultrule"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.this.id
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.agw_feip
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = local.agw_port_80
    port = 80
  }

  backend_address_pool {
    name = local.agw_pool
  }

  backend_http_settings {
    name                  = local.agw_settings
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = local.agw_listener
    frontend_ip_configuration_name = local.agw_feip
    frontend_port_name             = local.agw_port_80
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.agw_rule
    priority                   = 19500
    rule_type                  = "Basic"
    http_listener_name         = local.agw_listener
    backend_address_pool_name  = local.agw_pool
    backend_http_settings_name = local.agw_settings
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      redirect_configuration,
      request_routing_rule,
      rewrite_rule_set,
      ssl_certificate,
      trusted_root_certificate,
      url_path_map,
      tags,
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                          = "appgw-to-law"
  target_resource_id             = azurerm_application_gateway.this.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
