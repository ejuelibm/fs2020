#This Configuration will create a VPC, set up 2 zones each with a subnet, and place a virtual instance in each as well as deploy a load
#balancer attached to the servers. A simple cloud-init script will install nginx, to showcase an http response for proving out the example.
#This variables.tf file sets up our variables for the Terraform Configuration

#IBM Cloud Provider for Terraform Docs:  https://ibm-cloud.github.io/tf-ibm-docs/
#IBM VPC CLI reference:  https://cloud.ibm.com/docs/infrastructure/vpc?topic=vpc-infrastructure-cli-plugin-vpc-reference

#The Description tags below are used by Schematics during the Variables area to help the user understand what the Variable is for.
#The Default tag is the default value of the variable which can be overwritten by Schematics if the user wishes.

#To change the region, use the IBM Cloud CLI tool and the command 'ibmcloud regions' to get a list of regions.  Remember that each Region
#has it's own Image List with unique Image Identifiers so you will need to change that further down this file.
variable "ibmcloud_region" {
  description = "Preferred IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "vpc_name" {
  default = "vpc-fs2020-lab"
  description = "Name of your VPC"
}

variable "zone1" {
  default = "us-south-1"
  description = "Define the 1st zone of the region"
}

variable "zone2" {
  default = "us-south-2"
  description = "Define the 2nd zone of the region"
}

variable "zone1_cidr" {
  default = "172.16.1.0/24"
  description = "CIDR block to be used for zone 1"
}

variable "zone2_cidr" {
  default = "172.16.2.0/24"
  description = "CIDR block to be used for zone 2"
}

variable "ssh_public_key" {
  default = ""
  description = "SSH Public Key contents to be used"
}

#Use 'ibmcloud is images list' command in IBM CLI to obtain a list of Images.  This command is Region specific.
#See https://cloud.ibm.com/docs/cli?topic=vpc-infrastructure-cli-plugin-vpc-reference for IBM CLI usage
variable "image" {
  default = "r006-14140f94-fcc4-11e9-96e7-a72723715315"
  description = "OS Image ID to be used for virtual instances"
}

#Use 'imbcloud is instance-profiles' command in IBM CLI to obtain list of Profiles
#See https://cloud.ibm.com/docs/cli?topic=vpc-infrastructure-cli-plugin-vpc-reference for IBM CLI usage
variable "profile" {
  default = "cx2-2x4"
  description = "Instance profile to be used for virtual instances"
}
