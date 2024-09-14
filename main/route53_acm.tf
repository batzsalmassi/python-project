
# ACM Certificate in CloudGuru (sandbox) Account
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name              = "shodapp.seansalmassi.com"
  validation_method        = "DNS"
  create_route53_records   = false  # We are manually creating DNS records in the personal account

  tags = {
    Name = "shodapp.seansalmassi.com"
  }
}


# Fetch ACM certificate details from CloudGuru (sandbox) account
data "aws_acm_certificate" "acm_cert" {
  domain      = "shodapp.seansalmassi.com"
  statuses    = ["PENDING_VALIDATION"]
  most_recent = true
}
  
# Create DNS validation CNAME record in Personal Account's Route 53
resource "aws_route53_record" "acm_validation" {
  provider = aws.personal  # Use the personal account provider alias
  zone_id  = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of your personal domain

  name = data.aws_acm_certificate.acm_cert.domain_validation_options[0].resource_record_name
  type = data.aws_acm_certificate.acm_cert.domain_validation_options[0].resource_record_type
  ttl  = 60

  records = [
    data.aws_acm_certificate.acm_cert.domain_validation_options[0].resource_record_value
  ]

  depends_on = [module.acm]
}

# Create A record in Personal Account after successful ACM validation
resource "aws_route53_record" "seansalmassi-com" {
  provider = aws.personal  # Use the personal account provider alias
  zone_id  = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of your personal domain

  name    = "shodapp.seansalmassi.com"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name  # ALB DNS name from personal account
    zone_id                = module.alb.lb_zone_id   # ALB hosted zone ID from personal account
    evaluate_target_health = true
  }

  depends_on = [aws_route53_record.acm_validation]  # Ensure validation record exists before A record
}

# Optional delay for ACM validation to complete
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