#Set our Provider to IBM VPC Gen2

provider "ibm" {
  generation            = 2
  region                = "${var.ibmcloud_region}"
}
