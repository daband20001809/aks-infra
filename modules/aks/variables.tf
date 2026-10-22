variable "name" {
  description = "AKS cluster name (also used as dns_prefix)"
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_id" {
  description = "Scope for the AGIC Reader role"
  type        = string
}

variable "kubernetes_version" {
  description = "null = default version suggested by Azure"
  type        = string
  default     = null
}

# ---------- Node pool ----------
variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "node_min_count" {
  type    = number
  default = 2
}

variable "node_max_count" {
  type    = number
  default = 4
}

# ---------- Network ----------
variable "aks_subnet_id" {
  type = string
}

variable "service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}

# ---------- Integrations ----------
variable "log_analytics_workspace_id" {
  description = "Workspace for Container Insights"
  type        = string
}

variable "appgw_id" {
  description = "Application Gateway used by the AGIC add-on"
  type        = string
}

variable "appgw_subnet_id" {
  description = "App Gateway subnet (AGIC needs Network Contributor on it)"
  type        = string
}

variable "acr_id" {
  description = "ACR the kubelet identity pulls from"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
