variable namespace {
  type = string
  default = "wsronek-ns1"
}

variable api-creds-p12 {
  type = string
  default = "/Users/w.sronek/Documents/terraform/p12/acmecorp.staging.api-creds.p12"
}

variable api-endpoint {
  type = string
  default = "https://acmecorp.staging.volterra.us/api"
}

variable app-name {
  type = string
  default = "boutique"
}

variable app-frontend-service-name {
  type = string
  default = "boutique-frontend"
}

