# iTop on EKS with RDS MySQL - Terraform Deployment

This Terraform configuration deploys iTop (IT Operations Portal) on Amazon EKS with RDS MySQL backend.

## Architecture

- **VPC**: Custom VPC with public/private subnets across 3 AZs
- **EKS**: Managed Kubernetes cluster with OIDC provider enabled
- **RDS**: MySQL 8.0 instance in private subnets
- **Security**: Network isolation, secrets management, encrypted storage

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl

## Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **Configure kubectl:**
   ```bash
   aws eks --region us-west-2 update-kubeconfig --name itop-eks-cluster
   ```

5. **Get iTop ALB URL:**
   ```bash
   kubectl get ingress itop-ingress -n itop
   ```

## Access iTop

After deployment, access iTop via the ALB DNS name. The application will show the iTop setup page where you can complete the initial configuration. Database connectivity is automatically configured via Kubernetes secrets and ConfigMaps.

**Note**: It may take 2-3 minutes for the ALB to become available after deployment.

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Security Features

- RDS in private subnets only
- Security groups restricting database access to EKS nodes only
- Kubernetes secrets for database credentials
- Encrypted RDS storage
- Network isolation via VPC

## Customization

Modify `variables.tf` to customize:
- AWS region
- Instance types
- Node group sizing
- Database configuration