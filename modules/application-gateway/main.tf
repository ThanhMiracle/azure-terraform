locals {
  gateway_ip_configuration_name  = "gateway-ip-configuration"
  frontend_ip_configuration_name = "frontend-ip-configuration"
  frontend_port_name             = "frontend-port"
  backend_address_pool_name      = "backend-address-pool"
  backend_http_settings_name     = "backend-http-settings"
  http_listener_name             = "http-listener"
  request_routing_rule_name      = "request-routing-rule"
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  enable_http2        = var.enable_http2

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_ip_addresses
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = var.backend_path
    port                  = var.backend_port
    protocol              = var.backend_protocol
    request_timeout       = var.request_timeout
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = var.rule_priority
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  tags = var.tags
}
