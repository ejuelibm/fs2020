#This file sets up our Load Balancer

#Define our LB and it will cover Subnet 1 and Subnet 2
resource "ibm_is_lb" "lb1" {
  name = "${var.vpc_name}-lb"
  subnets = ["${ibm_is_subnet.subnet1.id}","${ibm_is_subnet.subnet2.id}"]
}

#Define our LB pool using Round Robin and other details.
resource "ibm_is_lb_pool" "lb1-pool" {
  lb = "${ibm_is_lb.lb1.id}"
  name = "${var.vpc_name}-lb1-pool"
  protocol = "http"
  algorithm = "round_robin"
  health_delay = "5"
  health_retries = "2"
  health_timeout = "2"
  health_type = "http"
  health_monitor_url = "/"
}

#Provides a load balancer listener resource. This allows the load balancer listener to be created, updated, and cancelled
resource "ibm_is_lb_listener" "lb1-listener" {
  lb = "${ibm_is_lb.lb1.id}"
  default_pool = "${element(split("/", ibm_is_lb_pool.lb1-pool.id),1)}"
  port = "80"
  protocol = "http"
}

#Tell our LB to send traffic to Instance 1
resource "ibm_is_lb_pool_member" "lb1-pool-member1" {
  count = 1
  lb = "${ibm_is_lb.lb1.id}"
  pool = "${ibm_is_lb_pool.lb1-pool.id}"
  port = "80"
  target_address = "${ibm_is_instance.instance1.primary_network_interface.0.primary_ipv4_address}"
}

#Tell our LB to send traffic to Instance 2
resource "ibm_is_lb_pool_member" "lb1-pool-member2" {
  count = 1
  lb = "${ibm_is_lb.lb1.id}"
  pool = "${ibm_is_lb_pool.lb1-pool.id}"
  port = "80"
  target_address = "${ibm_is_instance.instance2.primary_network_interface.0.primary_ipv4_address}"
}
