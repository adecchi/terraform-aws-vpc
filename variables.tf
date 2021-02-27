#####################
# GLOBAL VARIABLES  #
#####################
variable "resources_timeouts" {
  description = "Default Terraform Timeout for AWS Resource creation"
  type        = string
  default     = "5m"
}

###############################
# VARIABLES FOR VPC RESOURCES #
###############################
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "Terraform"
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true if we want to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true if we want to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_classiclink" {
  description = "Should be true if we want to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "enable_classiclink_dns_support" {
  description = "Should be true if we want to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "tags" {
  description = "A map of tags to be added to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags to be added to the VPC"
  type        = map(string)
  default     = {}
}

#####################################
# VARIABLES PUBLIC SUBNET RESOURCES #
#####################################
variable "public_subnets" {
  description = "Public subnets list inside the VPC"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of AZs names or IDs in the region"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Must be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on public subnet, should be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on subnet, should be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = false
}

variable "public_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Should be of equal length to the corresponding IPv4 subnet list"
  type        = list(string)
  default     = []
}

variable "public_subnet_suffix" {
  description = "Suffix to append to the public subnets name"
  type        = string
  default     = "public"
}

variable "public_subnet_tags" {
  description = "Additional tags to be added to the public subnets"
  type        = map(string)
  default     = {}
}

######################################
# VARIABLES PRIVATE SUBNET RESOURCES #
######################################
variable "private_subnets" {
  description = "Private subnets list inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on private subnet, should be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "private_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Should be of equal length to the corresponding IPv4 subnet list"
  type        = list(string)
  default     = []
}

variable "private_subnet_suffix" {
  description = "Suffix to append to the private subnets name"
  type        = string
  default     = "private"
}

variable "private_subnet_tags" {
  description = "Additional tags to be added to the private subnets"
  type        = map(string)
  default     = {}
}
#############################################
# VARIABLE PUBLIC SECURITY GROUPS RESOURCES #
#############################################
variable "public_security_group" {
  description = "Port, Protocol, CIDR BLOCK to allow connection to a AWS resources"
  type = map(object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {}
}

variable "public_security_group_tags" {
  description = "Additional tags to be added to the public security groups"
  type        = map(string)
  default     = {}
}
variable "public_security_group_suffix" {
  description = "Suffix to append to the private security groups name"
  type        = string
  default     = "public"
}

##############################################
# VARIABLE PRIVATE SECURITY GROUPS RESOURCES #
#############################################
variable "private_security_group" {
  description = "Port, Protocol, CIDR BLOCK to allow connection to a AWS resources"
  type = map(object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {}
}

variable "private_security_group_tags" {
  description = "Additional tags to be added to the private security groups"
  type        = map(string)
  default     = {}
}

variable "private_security_group_suffix" {
  description = "Suffix to append to the private security groups name"
  type        = string
  default     = "private"
}

########################################
# VARIABLES INTERNET GATEWAY RESOURCES #
########################################
variable "create_igw" {
  description = "Validate if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = true
}

variable "igw_tags" {
  description = "Additional tags to be added to the internet gateway"
  type        = map(string)
  default     = {}
}

#################################
# VARIABLE ELASTIC IP RESOURCES #
#################################
variable "nat_eip_tags" {
  description = "Additional tags to be added to the NAT EIP"
  type        = map(string)
  default     = {}
}

#########################
# NAT GATEWAY RESOURCES #
#########################
variable "enable_nat_gateway" {
  description = "Must be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "nat_gateway_tags" {
  description = "Additional tags to be added to the NAT gateways"
  type        = map(string)
  default     = {}
}

#####################################
# VARIABLES PUBLIC ROUTES RESOURCES #
#####################################
variable "public_route_table_tags" {
  description = "Additional tags to be added to the public route tables"
  type        = map(string)
  default     = {}
}

######################################
# VARIABLES PRIVATE ROUTES RESOURCES #
######################################
variable "private_route_table_tags" {
  description = "Additional tags to be added to the private route tables"
  type        = map(string)
  default     = {}
}