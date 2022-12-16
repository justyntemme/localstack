# Variables
variable "keypair" {
  type    = string
  default = "user-key"   # name of keypair created 
}

variable "network" {
  type    = string
  default = "private" # default network to be used
}

variable "security_groups" {
  type    = list(string)
  default = ["default"]  # Name of default security group
}

# Data sources
## Get Image ID
data "openstack_images_image_v2" "image" {
  name        = "debian-10-openstack-amd64" # Name of image to be used
  most_recent = true
}

## Get flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = "m1.small" # flavor to be used
}

# Create an instance
resource "openstack_compute_instance_v2" "server" {
  name            = "k8s-controller"  #Instance name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = var.security_groups

  network {
    name = var.network
  }
}

# Output VM IP Address
output "serverip" {
 value = openstack_compute_instance_v2.server.access_ip_v4
}

# Add Floating ip
resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "external-network"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.server.id
}

# Output VM IP Addresses
output "server_private_ip" {
 value = openstack_compute_instance_v2.server.access_ip_v4
}
output "server_floating_ip" {
 value = openstack_networking_floatingip_v2.fip1.address
}
