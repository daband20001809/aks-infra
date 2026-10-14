variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "location" {
  type    = string
  default = "southeastasia"
}

variable "prefix" {
  description = "prefix for naming resources"
  type        = string
  default     = "appbth"
}

variable "suffix" {
  description = "suffix for naming resources"
  type        = string
  default     = "lab01"

  validation {
    condition     = can(regex("^[a-z0-9]{1,20}$", var.suffix))
    error_message = "Please follow the naming convention."
  }
}

# ---------- Network ----------
variable "vnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "Azure CNI: IP for node and pod"
  type        = string
  default     = "10.10.0.0/20"
}

variable "appgw_subnet_cidr" {
  description = "App Gateway subnet"
  type        = string
  default     = "10.10.16.0/24"
}

variable "service_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.0.0.10"
}

# ---------- AKS ----------
variable "kubernetes_version" {
  description = "null = default version that suggested by Azure"
  type        = string
  default     = null
}

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

# ---------- App Gateway / WAF ----------
variable "appgw_capacity" {
  description = "App Gateway instance"
  type        = number
  default     = 1
}

variable "waf_mode" {
  description = "Prevention or detection"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_mode)
    error_message = "The waf_mode must be Prevention or Detection."
  }
}

# ---------- DNS ----------
variable "dns_zone" {
  description = "Your domain"
  type        = string
}

variable "app_subdomain" {
  type    = string
  default = "appbth"
}

variable "use_azure_dns" {
  description = "true = create DNS Zone and A record"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
  default = {
    project = "appbth-lab"
    purpose = "learning"
  }
}
