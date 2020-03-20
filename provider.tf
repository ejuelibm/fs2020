#Set our Provider to IBM VPC Gen2 using the Region defined in variables.tf

provider "ibm" {
  generation            = 2
  region                = "${var.ibmcloud_region}"
}
