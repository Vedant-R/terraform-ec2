variable "region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

provider "aws" {
  region = "${var.region}"
}

variable "ubuntu_version" {
  type        = "string"
  description = "Ubuntu OS version"
  default     = "16.04"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "custom_sg1" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "quicksight-sg"
  vpc_id              = "vpc-7c5cd518"
}

module "custom_sg2" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "quicksight-sg2"
  vpc_id              = "vpc-7c5cd518"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      source_security_group_id = "${module.quicksight_sg.this_security_group_id}"
    },

  ]
  number_of_computed_ingress_with_source_security_group_id = 1


  computed_egress_with_source_security_group_id = [
  {
    from_port                = 5439
    to_port                  = 5439
    protocol                 = "tcp"
    description              = "For redshift"
    source_security_group_id = "${module.quicksight_sg.this_security_group_id}"
  },
  ]
  number_of_computed_egress_with_source_security_group_id = 1
}



module "ec2_cluster" {
   source = "terraform-aws-modules/ec2-instance/aws"


   name           = "my-cluster"
   instance_count = 1


   ami                    = "${data.aws_ami.ubuntu.image_id}"
   instance_type          = "t2.micro"
   monitoring             = true
   vpc_security_group_ids = ["${module.quicksight_sg.this_security_group_id}", "${module.quicksight_sg2.this_security_group_id}"]
   subnet_id              = "subnet-74a8cd02"


   tags = {
     Terraform = "true"
     Environment = "dev"
   }
 }

output "instance_id" {
  value = "${module.ec2_cluster.id}"
}
