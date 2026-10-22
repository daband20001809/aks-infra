output "zone_id" {
  value = azurerm_dns_zone.this.id
}

output "name_servers" {
  description = "Set these at your domain registrar"
  value       = azurerm_dns_zone.this.name_servers
}

output "fqdn" {
  value = trimsuffix(azurerm_dns_a_record.this.fqdn, ".")
}
