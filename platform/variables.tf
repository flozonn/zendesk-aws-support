variable "region" {
  description = "Region to deploy"
  type        = string
}
variable "id_lookup_bucket" {
  description = "bucket name to host id lookups"
  type        = string
}

variable "zendesk_token" {
  description = "Zendesk API key"
  type        = string
}

variable "zendesk_subdomain" {
  description = "Zendesk subdomain"
  type        = string
}

variable "zendesk_admin_email" {
  description = "Zendesk admin email linked to the API key"
  type        = string
}
variable "bearer_token" {
  description = "Bearer token to be used by Zendesk webhooks"
  type        = string
}





