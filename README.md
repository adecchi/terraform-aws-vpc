# AWS VPC Terraform module
These types of resources are supported:

* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Security Groups](https://www.terraform.io/docs/providers/aws/r/security_group.html)

## Usage

```hcl
module "tienda_vpc" {
  source               = "git@github.com:adecchi/terraform-aws-vpc.git?ref=tags/0.0.1"
  name                 = "tienda-vpc"
  cidr                 = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  public_security_group = {
    "ssh-internet" = {
      from_port   = "22",
      to_port     = "22",
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "SSH"
    },
    "http-internet" = {
      from_port   = "80",
      to_port     = "80",
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "HTTP"
    },
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| private_subnet_ids | List of IDs of private subnets |
| public_subnet_ids | List of IDs of public subnets |
| private_security_group_id | IDs of Private Security Group |
| public_security_group_id | IDs of Public Security Group |