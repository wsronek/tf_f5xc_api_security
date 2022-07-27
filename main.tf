terraform {
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.9"
    }
  }
}

provider "volterra" {
  api_p12_file     = var.api-creds-p12
  url              = var.api-endpoint
}

resource "volterra_api_definition" "this" {
  name      = "${var.app-name}-api-definition"
  namespace = var.namespace

  swagger_specs = ["https://acmecorp.staging.volterra.us/api/object_store/namespaces/wsronek-ns1/stored_objects/swagger/wsronek-boutique-swagger/v1-22-07-18"]
}

resource "volterra_origin_pool" "this" {
  name                   = "api-protection-${var.app-name}-origin"
  namespace              = var.namespace
  description            = "Origin pool pointing to ${var.app-name} frontend k8s service running on private k8s cluster"
  loadbalancer_algorithm = "ROUND ROBIN"

  origin_servers {
    k8s_service {
      inside_network  = false
      outside_network = false
      vk8s_networks   = true
      service_name    = "${var.app-frontend-service-name}.${var.namespace}"
      site_locator {
        site {
          name      = "wsronek-pz01"
          namespace = "system"
        }
      }
    }
  }
  port               = 80
  no_tls             = true
  endpoint_selection = "LOCAL_PREFERRED"
}

resource "volterra_http_loadbalancer" "this" {
  name                            = "api-protection-${var.app-name}"
  namespace                       = var.namespace
  description                     = "HTTPS loadbalancer object ${var.app-name} app"
  domains                         = ["api-protection-${var.app-name}.acmecorp-stage.f5xc.app"]
  advertise_on_public_default_vip = true
  no_service_policies             = true
  disable_rate_limit              = true
  round_robin                     = true
  service_policies_from_namespace = true
  no_challenge                    = true

  default_route_pools {
    pool {
      name      = volterra_origin_pool.this.name
      namespace = var.namespace
    }
  }

  https_auto_cert {
    add_hsts      = false
    http_redirect = false
    no_mtls       = true
  }

  api_definition {
    name = volterra_api_definition.this.name
    namespace = var.namespace
  }
}
