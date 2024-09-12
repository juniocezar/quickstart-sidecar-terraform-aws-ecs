output "ecs_cluster_arn" {
  value       = var.ecs_cluster_name == "" ? aws_ecs_cluster.sidecar_cluster[0].arn : null
  description = "ECS cluster ARN"
}

output "load_balancer_arn" {
  value       = var.deploy_load_balancer ? aws_lb.sidecar_nlb[0].arn : null
  description = "Load balancer ARN"
}

output "load_balancer_dns" {
  value       = var.deploy_load_balancer ? aws_lb.sidecar_nlb[0].dns_name : null
  description = "Sidecar load balancer DNS endpoint"
}

output "security_group_id" {
  value       = aws_security_group.sidecar_sg.id
  description = "Sidecar security group id"
}
