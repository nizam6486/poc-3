module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    main = {
      name = "main-node-group"

      instance_types = var.node_group_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      ami_type               = "AL2_x86_64"
      capacity_type          = "ON_DEMAND"
      disk_size              = 20
      force_update_version   = false
      use_custom_launch_template = false

      update_config = {
        max_unavailable_percentage = 33
      }

      labels = {
        role = "main"
      }
    }
  }

  tags = {
    Environment = "poc"
    Terraform   = "true"
  }
}