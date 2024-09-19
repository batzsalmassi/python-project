module "waf" {
  source  = "umotif-public/waf-webaclv2/aws"
  version = "~> 5.0.0"

  name_prefix            = "shodan_waf"
  alb_arn                = module.alb.lb_arn # the arn of the alb 
  create_alb_association = true              # associate the alb arn to Waf
  allow_default_action   = false             # block all the request https

  providers = {
    aws = aws.us-east
  }

  # it's for show the logs of allow or block
  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "shodan-app"
    sampled_requests_enabled   = true
  }
  rules = [
    {
      # this rule for allow access to app.
      name     = "IpSetRule-0"
      priority = "1"
      action   = "allow"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-specific-ip"
        sampled_requests_enabled   = true
      }

      # the arn of the ip
      ip_set_reference_statement = {
        arn = aws_wafv2_ip_set.allow_ips.arn
      }
    },
    {
      # this rule to Allow results pages
      name     = "Allow_results_html"
      priority = "0"

      action = "allow"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RegexBadBotsUserAgent-metric"
        sampled_requests_enabled   = false
      }

      # You need to previously create you regex pattern
      # Refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set
      # for all of the options available.
      regex_pattern_set_reference_statement = {
        # url_path = {}
        # the arn of the regex
        arn = aws_wafv2_regex_pattern_set.allowed-url.arn
        field_to_match = {
          uri_path = "{}"
        }
        priority = 0
        type     = "LOWERCASE" # The text transformation type
      }
    },
    {
      # this rule to Allow results pages
      name     = "Block_all_routes_that_not_allowed"
      priority = "5"

      action = "block"

      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RegexBadBotsUserAgent-metric"
        sampled_requests_enabled   = false
      }

      # You need to previously create you regex pattern
      # Refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set
      # for all of the options available.
      regex_pattern_set_reference_statement = {
        # url_path = {}
        # the arn of the regex
        arn = aws_wafv2_regex_pattern_set.invalid_url.arn
        field_to_match = {
          uri_path = "{}"
        }
        priority = 0
        type     = "LOWERCASE" # The text transformation type
      }
    }
  ]
}



# the region when the ALB exsit 
provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}

# ipsets, allow only my ip
resource "aws_wafv2_ip_set" "allow_ips" {
  name               = "sean-ip-and-shlomo"
  description        = "IPset"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = [
    "77.137.78.61/32",
    "2.54.190.165/32",
    "84.228.161.67/32",
    "31.154.46.114/32",
       "213.57.17.130/32"
  ]
}


# creare regex to block after the / 
resource "aws_wafv2_regex_pattern_set" "invalid_url" {
  name  = "block_all_after_slash"
  scope = "REGIONAL"

  regular_expression {
    # block all after the / 
    regex_string = "^/.+"
  }
}


# creare regex to block after the / 
resource "aws_wafv2_regex_pattern_set" "allowed-url" {
  name  = "allow-spesific-html"
  scope = "REGIONAL"

  regular_expression {
    # block all after the / 
    regex_string = "^/.host_results.html+"
  }

  regular_expression {
    # block all after the / 
    regex_string = "^/.results.html+"
  }

  regular_expression {
    # block all after the / 
    regex_string = "^/search_by_ip.html+"
  }
  regular_expression {
    # block all after the / 
    regex_string = "^/search_by_filters.html+"
  }
}
