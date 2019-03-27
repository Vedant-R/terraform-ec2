# terraform-ec2
Creating ec2 instances using terraform, also creating custom security groups with custom ingress and egress rules and attaching it to the ec2 cluster for instances in same security groups to access the ec2 cluster.

## Requirements

- terraform `brew install terraform`
- aws account with setup

## How to run

Run the following commands:

- `terraform plan` (This will provide you with your plan)
- `terraform apply` (This will spin a ec2 cluster)
- `terraform destroy` (This will destroy the cluster)
