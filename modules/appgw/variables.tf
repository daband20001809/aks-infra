variable "name" {
  description = "Application Gateway name"
  type        = string
}

variable "waf_policy_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  description = "Dedicated App Gateway subnet ID"
  type        = string
}

variable "capacity" {
  description = "App Gateway instance count"
  type        = number
  default     = 1
}

variable "waf_mode" {
  description = "Prevention or Detection"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_mode)
    error_message = "The waf_mode must be Prevention or Detection."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace that receives App Gateway logs/metrics"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
