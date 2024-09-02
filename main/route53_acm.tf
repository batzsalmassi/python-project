resource "aws_route53_record" "seansalmassi-com" {
  zone_id = "Z00891131OSP4IF3CZM29"  # Hosted zone ID of the domain spider-shlomo.com
  
  # send Delay untile the module acm will finish Delay of 60 sec
  depends_on = [module.acm, null_resource.delay_acm]
  name    = "shodapp.seansalmassi.com"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name # dns name of the alb
    zone_id                = module.alb.lb_zone_id  # The hosted zone ID of the load balancer
    evaluate_target_health = true  # Set to true if you want Route 53 to evaluate the health of the target
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "shodapp.seansalmassi.com"
  validation_method = "DNS"
  zone_id     = "Z00891131OSP4IF3CZM29"   # Hosted zone ID of the domain spider-shlomo.com

#   subject_alternative_names = [
#     "app.spider-shlomo.com"
#   ]

  # create validation_record_fqdns in route53
  create_route53_records  = true
  validation_record_fqdns = [
    "_689571ee9a5f9ec307c512c5d851e25a.seansalmassi.com",
  ]

  tags = {
    Name = "shodapp.seansalmassi.com"
 
  }
    # Add a delay after ACM creation
  depends_on = [null_resource.delay_acm]
}
# check if its runinin on linux or window
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