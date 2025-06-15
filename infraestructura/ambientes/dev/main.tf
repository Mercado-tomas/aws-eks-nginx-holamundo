provider "aws" {
  region = var.aws_region
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  aws_region    = var.aws_region
  cluster_name  = "eks-aws-ngix-dev"
  environment   = "dev"
}

# Configurar kubeconfig para acceder al clúster
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
  }

  depends_on = [module.eks_cluster]
}
