variable "aws_region" {
   type = string
   default = "ap-southeast-2"
}
variable "ami_id" {
  type = string
  default = "ami-0b8d527345fdace59"
}
variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "key_name" {
  type = string
  default = "docker_c1"
}
variable "vpc_cidr" {
    type = string
}
variable "public1_cidr" {
    type = string
}
variable "private1_cidr" {
    type = string
}
variable "private2_cidr" {
    type = string
}

variable "availability_zone1" {
  type = string
}
variable "availability_zone2" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}


