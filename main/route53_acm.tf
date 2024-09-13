# ACM Certificate in CloudGuru AWS sandbox
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name       = "shodapp.seansalmassi.com"
  validation_method = "DNS"

  # Do not create Route 53 DNS validation records in CloudGuru, we will handle it manually in the personal account
  create_route53_records = false

  tags = {
    Name = "shodapp.seansalmassi.com"
  }
}

# Route 53 Record for ACM Validation in Personal AWS Account (CNAME Record)
resource "aws_route53_record" "acm_validation" {
  provider = aws.personal  # Use personal AWS account for DNS validation records

  # Loop through all domain validation options (for multi-domain certificates)
  for_each = { for option in module.acm.acm_certificate_domain_validation_options : option.domain_name => option }

  zone_id = "Z00891131OSP4IF3CZM29" # Hosted zone ID in the personal account

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60

  lifecycle {
    create_before_destroy = true  # Ensure DNS record is fully created before any further actions
  }

  # Ensure the ACM certificate in CloudGuru is created before the DNS validation record
  depends_on = [module.acm]
}

# ACM Certificate Validation - Waits for DNS Record Propagation in Personal AWS Account
resource "aws_acm_certificate_validation" "this" {
  certificate_arn        = module.acm.acm_certificate_arn
  validation_record_fqdns = [for option in module.acm.acm_certificate_domain_validation_options : option.resource_record_name]

  # Ensure DNS validation records in personal AWS account are created before certificate validation
  depends_on = [aws_route53_record.acm_validation]
}

# Route 53 Record for ALB in Personal AWS Account
resource "aws_route53_record" "seansalmassi-com" {
  provider = aws.personal  # Use personal AWS account for DNS records

  zone_id = "Z00891131OSP4IF3CZM29" # Hosted zone ID in the personal account

  name       = "shodapp.seansalmassi.com"
  type       = "A"

  alias {
    name                   = module.alb.lb_dns_name # DNS name of the ALB
    zone_id                = module.alb.lb_zone_id  # Hosted zone ID of the ALB
    evaluate_target_health = true
  }

  depends_on = [module.acm]
}
