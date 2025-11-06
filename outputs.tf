output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.itop.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.itop.port
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "itop_url" {
  description = "iTop application URL (available after ALB is provisioned)"
  value       = "http://${try(kubernetes_ingress_v1.itop.status[0].load_balancer[0].ingress[0].hostname, "pending")}"
}

output "get_alb_url" {
  description = "Command to get the ALB URL"
  value       = "kubectl get ingress itop-ingress -n itop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}