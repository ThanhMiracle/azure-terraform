variable "name" {
  description = "Application Gateway name"
  type        = string
}

variable "public_ip_name" {
  description = "Application Gateway public IP name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the dedicated Application Gateway subnet"
  type        = string
}

variable "backend_ip_addresses" {
  description = "Private IP addresses registered in the backend pool"
  type        = list(string)
}

variable "sku_name" {
  description = "Application Gateway SKU name"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "Application Gateway SKU tier"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Application Gateway instance capacity"
  type        = number
  default     = 1
}

variable "frontend_port" {
  description = "Public HTTP listener port"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend HTTP port"
  type        = number
  default     = 80
}

variable "backend_protocol" {
  description = "Protocol used to communicate with the backend"
  type        = string
  default     = "Http"
}

variable "backend_path" {
  description = "Path prepended to backend requests"
  type        = string
  default     = "/"
}

variable "request_timeout" {
  description = "Backend request timeout in seconds"
  type        = number
  default     = 30
}

variable "rule_priority" {
  description = "Request routing rule priority"
  type        = number
  default     = 100
}

variable "enable_http2" {
  description = "Enable HTTP/2 on the frontend listener"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Application Gateway resources"
  type        = map(string)
  default     = {}
}
