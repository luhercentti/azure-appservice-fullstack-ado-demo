output "api_url" {
  value = "https://${azurerm_windows_web_app.api.default_hostname}"
}

output "frontend_url" {
  value = "https://${azurerm_static_web_app.frontend.default_host_name}"
}