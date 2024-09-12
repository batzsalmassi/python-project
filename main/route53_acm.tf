# ACM Certificate in CloudGuru AWS sandbox
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name       = "shodapp.seansalmassi.com"
  validation_method = "DNS"

  create_route53_records = false  # DNS records will be managed manually in the personal account

  tags = {
    Name = "shodapp.seansalmassi.com"
  }

  depends_on = [null_resource.delay_acm]
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

  zone_id = "Z00891131OSP4IF3CZM29"  # Hosted zone ID in the personal account

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

# Route 53 Record for ALB in Personal Account
resource "aws_route53_record" "seansalmassi-com" {
  provider = aws.personal

  zone_id = "Z00891131OSP4IF3CZM29"  # Hosted zone ID in the personal account

  depends_on = [module.acm, null_resource.delay_acm]
  name       = "shodapp.seansalmassi.com"
  type       = "A"

  alias {
    name                   = module.alb.lb_dns_name # DNS name of the ALB
    zone_id                = module.alb.lb_zone_id  # Hosted zone ID of the ALB
    evaluate_target_health = true
  }
}

# Delay Resource for ACM DNS Validation
resource "null_resource" "delay_acm" {
  provisioner "local-exec" {
    command = <<-EOT
      uname_out=$(uname 2>/dev/null || echo "Windows")
      case "$uname_out" in
          Linux*) sleep 60;;
          Darwin*) sleep 60;;  # macOS
          *) powershell -Command Start-Sleep -Seconds 60;;
      esac
    EOT
  }
}
