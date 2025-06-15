output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnets for the VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnets for the VPC"
  value       = module.vpc.public_subnets
}

