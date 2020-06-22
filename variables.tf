variable "aws_region" {
  type        = string
  description = "AWS Region this resource will be deployed"
  default     = "us-east-2"
}


variable "owner" {
  default = "sachinm"
}

variable "centos" {
  default = "ami-0f2b4fc905b0bd1f1"
}

variable "volume_size" {
  default = 30
}
variable "device_name" {
  default = "/dev/xvdb"
}


variable "mon_count" {
  default = 1
}

variable "osd_count" {
  default = 2
}

variable "client_count" {
  default = 0
}

variable "mon_instance_type" {
  default = "t2.medium"
}

variable "client_instance_type" {
  default = "t2.micro"
}

variable "osd_instance_type" {
  default = "t2.medium"
}

variable "project" {
  default = "kube"
}

variable "vpc_cidr" {
  default = "172.31.16.0/20"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile to be used"
  default     = "default"
}

variable "server_port" {
  type        = number
  default     = 80
  description = "Port the ec2 will listen on"
}


variable "all_cidr" {
  default = "0.0.0.0/0"
}

variable "aws_key_pair_name" {
  type        = string
  default     = null
  description = "AWS Key Pair Name"
}


variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
