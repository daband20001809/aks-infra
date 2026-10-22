variable "name" {
  description = "VNet name"
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "aks_subnet_cidr" {
  description = "Azure CNI: IP for node and pod"
  type        = string
}

variable "appgw_subnet_cidr" {
  description = "App Gateway subnet"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
