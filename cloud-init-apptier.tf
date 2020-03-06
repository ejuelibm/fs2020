#This defines what to install while provisioning the Virtual Servers.  In this case it will install nginx which is a web server.

data "template_cloudinit_config" "cloud-init-apptier" {
  base64_encode = false
  gzip = false
  part {
    content = <<EOF
#cloud-config
packages:
  - nginx

EOF
  }
}
