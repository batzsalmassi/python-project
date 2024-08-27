output "alb" {
    value = module.alb
}

output "lb_dns_name" {
    value       = "http://${module.alb.lb_dns_name}/"
    description = "DNS name of ALB."
}