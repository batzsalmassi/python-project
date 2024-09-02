output "alb" {
  value = module.alb
}

output "dns_a_record_route53" {
  value       = "https://${aws_route53_record.seansalmassi-com.name}"
  description = "a record for alb."
}