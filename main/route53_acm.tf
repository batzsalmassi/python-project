
# ACM Certificate in CloudGuru (sandbox) Account
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name            = "shodapp.seansalmassi.com"
  validation_method      = "DNS"
  create_route53_records = false # We are manually creating DNS records in the personal account

  tags = {
    Name = "shodapp.seansalmassi.com"
  }
}

# Create DNS validation CNAME record in Personal Account's Route 53
resource "aws_route53_record" "acm_validation" {
  provider = aws.personal  # Use the personal account provider alias
  for_each = {
    for dvo in module.acm.acm_certificate_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of your personal domain
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Validate the certificate
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = module.acm.acm_certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# Create A record in Personal Account after successful ACM validation
resource "aws_route53_record" "seansalmassi-com" {
  provider = aws.personal            # Use the personal account provider alias
  zone_id  = "Z00891131OSP4IF3CZM29" # Hosted zone ID of your personal domain

  name = "shodapp.seansalmassi.com"
  type = "A"

  alias {
    name                   = module.alb.lb_dns_name # ALB DNS name from personal account
    zone_id                = module.alb.lb_zone_id  # ALB hosted zone ID from personal account
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate_validation.cert]  # Ensure validation is complete before A record
}