provider "azurerm" {
  features {}
  subscription_id = "467adf56-8638-481d-bbca-8e430ba2bbc6"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-static-website"
  location = "New Zealand North"
}

resource "azurerm_storage_account" "storage" {
  name                     = "staticsite${random_id.unique.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "website" {
  storage_account_id = azurerm_storage_account.storage.id
  index_document     = "index.html"
  error_404_document = "error.html"
}

resource "random_id" "unique" {
  byte_length = 4
}

# azurerm_storage_static_website.storage

# --- Azure Front Door for better security and cipher control ---
resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = "frontdoor-${random_id.unique.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"  # Downgraded to Standard for cost savings
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  name                     = "fd-endpoint-${random_id.unique.hex}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

resource "azurerm_cdn_frontdoor_origin_group" "frontdoor_origin_group" {
  name                     = "fd-origin-group-${random_id.unique.hex}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  session_affinity_enabled = false

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

  health_probe {
    interval_in_seconds = 240
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "frontdoor_origin" {
  name                          = "fd-origin-${random_id.unique.hex}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group.id
  enabled                       = true

  certificate_name_check_enabled = true
  host_name                      = "staticsite88c8e1d2.z44.web.core.windows.net"
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = "staticsite88c8e1d2.z44.web.core.windows.net"
  priority                       = 1
  weight                         = 1000
}

# Note: Custom domain and route resources are commented out due to Terraform conflicts
# These have been manually configured in Azure Portal
# resource "azurerm_cdn_frontdoor_custom_domain" "frontdoor_custom_domain" {
#   name                     = "fd-custom-domain-${random_id.unique.hex}"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
#   dns_zone_id              = null
#   host_name                = "azureblob.cloudkraft.nz"
#
#   tls {
#     certificate_type = "ManagedCertificate"
#   }
# }

# resource "azurerm_cdn_frontdoor_route" "frontdoor_route" {
#   name                          = "fd-route-${random_id.unique.hex}"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontdoor_origin.id]
#   enabled                       = true
#
#   forwarding_protocol    = "HttpsOnly"
#   https_redirect_enabled = true
#   patterns_to_match      = ["/*"]
#   supported_protocols    = ["Http", "Https"]
#
#   cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain.id]
#   link_to_default_domain          = false
#
#   # Add comprehensive security headers for XSS protection
#   cdn_frontdoor_rule_set_ids = [azurerm_cdn_frontdoor_rule_set.security_headers.id]
# }

# Rule Set for Security Headers including XSS protection
resource "azurerm_cdn_frontdoor_rule_set" "security_headers" {
  name                     = "SecurityHeaders"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

# Content Security Policy - Primary XSS protection
resource "azurerm_cdn_frontdoor_rule" "csp_header" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "ContentSecurityPolicy"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "Content-Security-Policy"
      value         = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' fonts.googleapis.com; font-src 'self' fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# X-XSS-Protection header
resource "azurerm_cdn_frontdoor_rule" "xss_protection" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "XSSProtection"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 2
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "X-XSS-Protection"
      value         = "1; mode=block"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# X-Content-Type-Options to prevent MIME sniffing
resource "azurerm_cdn_frontdoor_rule" "content_type_options" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "ContentTypeOptions"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 3
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "X-Content-Type-Options"
      value         = "nosniff"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# X-Frame-Options to prevent clickjacking
resource "azurerm_cdn_frontdoor_rule" "frame_options" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "FrameOptions"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 4
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "X-Frame-Options"
      value         = "DENY"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# Referrer Policy
resource "azurerm_cdn_frontdoor_rule" "referrer_policy" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "ReferrerPolicy"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 5
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "Referrer-Policy"
      value         = "strict-origin-when-cross-origin"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# Strict Transport Security (HSTS)
resource "azurerm_cdn_frontdoor_rule" "hsts" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "HSTS"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 6
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "Strict-Transport-Security"
      value         = "max-age=31536000; includeSubDomains; preload"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

# Permissions Policy (formerly Feature Policy)
resource "azurerm_cdn_frontdoor_rule" "permissions_policy" {
  depends_on = [azurerm_cdn_frontdoor_rule_set.security_headers]

  name                      = "PermissionsPolicy"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security_headers.id
  order                     = 7
  behavior_on_match         = "Continue"

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "Permissions-Policy"
      value         = "camera=(), microphone=(), geolocation=(), interest-cohort=()"
    }
  }

  conditions {
    request_method_condition {
      match_values = ["GET", "POST"]
    }
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "frontdoor_waf" {
  name                              = "fdwaf${random_id.unique.hex}"
  resource_group_name               = azurerm_resource_group.rg.name
  sku_name                          = azurerm_cdn_frontdoor_profile.frontdoor.sku_name
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://azureblob.cloudkraft.nz/"
  custom_block_response_status_code = 403
  custom_block_response_body        = base64encode("Access denied due to security policy violation")

  # Custom rule for XSS protection (managed rules removed for Standard SKU)
  custom_rule {
    name                           = "BlockXSSAttempts"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "QueryString"
      operator           = "Contains"
      negation_condition = false
      match_values       = ["<script", "javascript:", "vbscript:", "onload=", "onerror=", "onclick="]
    }
  }

  # Block requests with suspicious user agents
  custom_rule {
    name                           = "BlockSuspiciousUserAgents"
    enabled                        = true
    priority                       = 2
    rate_limit_duration_in_minutes = 5
    rate_limit_threshold           = 20
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RequestHeader"
      operator           = "Contains"
      negation_condition = false
      match_values       = ["sqlmap", "nikto", "burp", "acunetix", "netsparker"]
      selector           = "User-Agent"
    }
  }

  # Rate limiting to prevent abuse
  custom_rule {
    name                           = "RateLimitRule"
    enabled                        = true
    priority                       = 3
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100
    type                           = "RateLimitRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["0.0.0.0/0", "::/0"]
    }
  }
}

# Note: Security policy association is commented out due to manual configuration
# resource "azurerm_cdn_frontdoor_security_policy" "frontdoor_security_policy" {
#   name                     = "fd-security-policy-${random_id.unique.hex}"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
#
#   security_policies {
#     firewall {
#       cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.frontdoor_waf.id
#
#       association {
#         domain {
#           cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain.id
#         }
#         patterns_to_match = ["/*"]
#       }
#     }
#   }
# }
