variable "zone_name" {
  description = "Your domain, e.g. example.com"
  type        = string
}

variable "record_name" {
  description = "Subdomain for the A record"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "target_resource_id" {
  description = "Public IP the A record aliases to"
  type        = string
}

variable "ttl" {
  type    = number
  default = 300
}

variable "tags" {
  type    = map(string)
  default = {}
}
