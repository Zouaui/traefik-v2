variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "availablity_zones" {
  type    = list(string)
  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"]
}

# variable "az" {
#     description = "azs"
#     default = ["eu-west-1a","eu-west-1b"]

# }
# variable "private_subnet_cidr_az1" {
#     description = "CIDR for the Private Subnet for AZ1"
#     default = "10.0.1.0/24"
# }

# variable "private_subnet_cidr_az2" {
#     description = "CIDR for the Private Subnet for AZ2"
#     default = "10.0.2.0/24"
# }


# variable "public_subnet_cidr_az1" {
#     description = "CIDR for the Public Subnet for AZ1"
#     default = "10.0.3.0/24"
# }
