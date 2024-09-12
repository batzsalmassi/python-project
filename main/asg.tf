# Autoscaling Group Module in CloudGuru AWS sandbox
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.0"

  name                      = "shodapp_auto_scaling_group"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 3
  health_check_type         = "EC2"
  health_check_grace_period = 200
  vpc_zone_identifier       = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  launch_template_name        = "shodan-app-launch-template"
  launch_template_description = "Launch template for ASG"
  update_default_version      = true
  image_id                    = data.aws_ami.amazon-linux.id
  key_name                    = aws_key_pair.TF-key.key_name
  instance_type               = var.instance_type[1]
  user_data                   = base64encode(templatefile("user_data.sh", { SHODAN_API_KEY = var.shodan_api_key }))
  security_groups             = [aws_security_group.Allow_services.id]

  target_group_arns = module.alb.target_group_arns
}

# Application Load Balancer Module in CloudGuru AWS sandbox
module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = "asg-prod"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.Allow_services.id]

  target_groups = [
    {
      name_prefix                = "Prod"
      backend_protocol           = "HTTP"
      backend_port               = 80
      vpc_id                     = module.vpc.vpc_id
      target_type                = "instance"
      protocol                   = 80
      target                     = "HTTP:80/"
      HealthCheckIntervalSeconds = 30
      HealthyThresholdCount      = 2
      UnhealthyThresholdCount    = 2
      HealthCheckPath            = "/status/200"
      matcher                    = "200"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Production"
  }
}

# Autoscaling Policies in CloudGuru AWS sandbox
resource "aws_autoscaling_policy" "MyScaleUpPolicy" {
  name                   = "MyScaleUpPolicy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = module.asg.autoscaling_group_name
  cooldown               = 60
  scaling_adjustment     = 2
}

resource "aws_autoscaling_policy" "MyScaleDownPolicy" {
  name                   = "MyScaleDownPolicy"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = module.asg.autoscaling_group_name
  cooldown               = 180
  scaling_adjustment     = -1
}

# CloudWatch Alarms in CloudGuru AWS sandbox
resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name          = "ScaleUp"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 40
  alarm_description   = "Scale up if CPU utilization is greater than 40% for 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.MyScaleUpPolicy.arn]

  dimensions = {
    autoscaling_group_name = module.asg.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name          = "ScaleDown"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale down if CPU utilization is less than 20% for 1 minute"
  alarm_actions       = [aws_autoscaling_policy.MyScaleDownPolicy.arn]

  dimensions = {
    autoscaling_group_name = module.asg.autoscaling_group_name
  }
}