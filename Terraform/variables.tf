variable "project_id" {
  type           = string
  default        = " gcp-terraform-as"
}

variable "used_region_1" {
  type           = string
  default        = "us-east1"
}

variable "used_region_2" {
  type           = string
  default        = "us-east2"
}

variable "vpc_name" {
  type           = string
  default        = "application-vpc"
}

variable "first_cider" {
  type           = string
  default        = "10.1.0.0/16"
}

variable "second_cider" {
  type           = string
  default        = "10.2.0.0/16"
}