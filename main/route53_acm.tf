# Create ACM certificate in CloudGuru account
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name              = "shodapp.seansalmassi.com"
  validation_method        = "DNS"  # DNS validation
  create_route53_records   = false  # Disable Route 53 record creation in CloudGuru account

  tags = {
    Name = "shodapp.seansalmassi.com"
  }
}

# Create CNAME record in personal account for DNS validation
resource "aws_route53_record" "acm_validation" {
  provider = aws.personal  # Record created in personal account
  zone_id  = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of the personal domain

  name    = module.acm.validation_record_fqdns[0]  # The ACM-generated DNS validation name
  type    = "CNAME"
  ttl     = 60

  records = [
    module.acm.validation_record_fqdns[0],  # The ACM-generated DNS validation value
  ]

  depends_on = [module.acm]
}

# Create A record in the personal account for routing traffic
resource "aws_route53_record" "seansalmassi_com" {
  provider = aws.personal  # A record created in personal account
  zone_id  = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of the personal domain

  name    = "shodapp.seansalmassi.com"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name  # ALB DNS name (probably in personal account)
    zone_id                = module.alb.lb_zone_id   # ALB hosted zone ID (probably in personal account)
    evaluate_target_health = true
  }

  depends_on = [aws_route53_record.acm_validation]  # Wait until the DNS validation is complete
}

# Delay resource for allowing time for ACM creation and validation
resource "null_resource" "delay_acm" {
  provider = aws.personal
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