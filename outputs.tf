# This file contains the output variables that we want to see when the plan is executed and completed.

#Floating IP address of Virtual Server 1
output "FloatingIP-1" {
    value = "${ibm_is_floating_ip.floatingip1.address}"
}

#Floating IP address of Virtual Server 1
output "FloatingIP-2" {
    value = "${ibm_is_floating_ip.floatingip2.address}"
}

#Hostname of our Load Balancer
output "LB-Hostname" {
    value = "http://${ibm_is_lb.lb1.hostname}"
}
