#This Configuration will create a VPC, set up 2 zones each with a subnet, and place a virtual instance in each as well as deploy a load
#balancer attached to the servers. A simple cloud-init script will install nginx, to showcase an http response for proving out the example.

#TF Docs:  https://ibm-cloud.github.io/tf-ibm-docs/
#CLI Docs:  https://cloud.ibm.com/docs/infrastructure/vpc?topic=vpc-infrastructure-cli-plugin-vpc-reference

#Import the details of an existing SSH Key
resource "ibm_is_ssh_key" "ssh1" {
  name       = "ssh1"
  public_key = "${var.ssh_public_key}"
}

#Create a VPC called vpc1
resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
}

#Provides a vpc address prefix resource. This allows vpc address prefix to be created, updated, and cancelled
resource "ibm_is_vpc_address_prefix" "vpc-ap1" {
  name = "vpc-ap1"
  zone = "${var.zone1}"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  cidr = "${var.zone1_cidr}"
}

#Provides a vpc address prefix resource. This allows vpc address prefix to be created, updated, and cancelled
resource "ibm_is_vpc_address_prefix" "vpc-ap2" {
  name = "vpc-ap2"
  zone = "${var.zone2}"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  cidr = "${var.zone2_cidr}"
}

#Create a subnet in Zone1
resource "ibm_is_subnet" "subnet1" {
  name            = "subnet1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.zone1_cidr}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap1"]
}

#Create a subnet in Zone2
resource "ibm_is_subnet" "subnet2" {
  name            = "subnet2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.zone2_cidr}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap2"]
}

#Create Virtual Server Instance 1
resource "ibm_is_instance" "instance1" {
  name    = "instance1"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet1.id}"
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone1}"
  keys = ["${ibm_is_ssh_key.ssh1.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}

#Create Virtual Server Instance 2
resource "ibm_is_instance" "instance2" {
  name    = "instance2"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet2.id}"
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone2}"
  keys = ["${ibm_is_ssh_key.ssh1.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}

#Give Virtual Server Instance 1 a Floating IP
resource "ibm_is_floating_ip" "floatingip1" {
  name = "fip1"
  target = "${ibm_is_instance.instance1.primary_network_interface.0.id}"
}

#Give Virtual Server Instance 2 a Floating IP
resource "ibm_is_floating_ip" "floatingip2" {
  name = "fip2"
  target = "${ibm_is_instance.instance2.primary_network_interface.0.id}"
}

#Rule 1: Allow inbound traffic on port 22
resource "ibm_is_security_group_rule" "sg1_tcp_rule_22" {
  depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  group     = "${ibm_is_vpc.vpc1.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "22"
    port_max = "22"
  }
}

#Rule 2: Allow inbound traffic on port 80
resource "ibm_is_security_group_rule" "sg1_tcp_rule_80" {
  depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  group     = "${ibm_is_vpc.vpc1.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "80"
    port_max = "80"
  }
}
