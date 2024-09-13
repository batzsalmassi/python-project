# ACM Certificate in CloudGuru AWS sandbox
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name       = "shodapp.seansalmassi.com"
  validation_method = "DNS"

  create_route53_records = false # DNS records will be managed manually in the personal account

  tags = {
    Name = "shodapp.seansalmassi.com"
  }
}

# Output for ACM Certificate ARN
output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

# Route 53 Record for ACM Validation in Personal Account
resource "aws_route53_record" "acm_validation" {
  provider = aws.personal

  for_each = { for option in module.acm.acm_certificate_domain_validation_options : option.domain_name => option }

  zone_id = "Z00891131OSP4IF3CZM29" # Hosted zone ID in the personal account

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60

  # Wait for DNS validation by querying Route 53
  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 Record for ALB in Personal Account
resource "aws_route53_record" "seansalmassi-com" {
  provider = aws.personal

  zone_id = "Z00891131OSP4IF3CZM29" # Hosted zone ID in the personal account

  name = "shodapp.seansalmassi.com"
  type = "A"

  alias {
    name                   = module.alb.lb_dns_name # DNS name of the ALB
    zone_id                = module.alb.lb_zone_id  # Hosted zone ID of the ALB
    evaluate_target_health = true
  }
}

# Route 53 Validation Record Propagation Check
data "aws_route53_record" "acm_validation" {
  provider = aws.personal

  for_each = { for option in module.acm.acm_certificate_domain_validation_options : option.domain_name => option }

  zone_id = "Z00891131OSP4IF3CZM29"
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
}

# ACM Certificate Validation with DNS Propagation Check
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = module.acm.acm_certificate_arn
  validation_record_fqdns  = [for option in data.aws_route53_record.acm_validation : option.fqdn]

  depends_on = [aws_route53_record.acm_validation]
}