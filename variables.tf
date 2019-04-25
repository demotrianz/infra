variable "access_key" {
description = "AWS access key"
default = "AKIA54CZHI73WZNQKN5W"
}

variable "secret_key" {
description = "AWS secret key"
default = "PGwez2EHCyRLBA6nIKi5SwQC6THak9++UmpP3kt3"
}

variable "region" {
description = "AWS region for hosting our your network"
default = "ap-southeast-1"
}

variable "key_name" {
description = "Key name for SSHing into EC2"
default = "Goutham.R"
}

variable "vpc_cidr" {
description = "CIDR for VPC"
default     = "172.0.0.0/16"
}

variable "Public_subnet_cidr" {
description = "CIDR for Public subnet"
default     = "172.0.1.0/24"
}

variable "Private_subnet_cidr" {
description = "CIDR for Public subnet"
default     = "172.0.2.0/24"
}

variable "amis" {
description = "ami for instances"
default     = "ami-0dad20bd1b9c8c004"
}
