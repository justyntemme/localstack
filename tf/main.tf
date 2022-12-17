variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

#### VM parameters
variable "flavor_http" {
  type    = string
  default = "t2.medium"
}

variable "network_http" {
  type = map(string)
  default = {
    subnet_name = "subnet-http"
    cidr        = "192.168.1.0/24"
  }
}

resource "openstack_compute_keypair_v2" "admin-key" {
  name       = "admin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCEnqNV952JH/92X+98nfvGOcxFmPthfAR77IZyjSh27uAmXOYQ3lLmkNN7m/AW/kSxxeEs7ZHRyygGqBqG8ifp98uRqSsq1gF5EIkPKBeH8j5/OtJxWxNx1xuSrGD/Ukyqy6DS4IBu46hV6ASfOTRTcYcELeRYBRPf2/8s69epVBE0anWl0WqOH2FN4z2Sgv7Yx/YYW739v2FK7ivZ/WrZ3/9mO6UVbE3tqk3RsHaWuk5+j8Dh2yHUYDCGhGFvjqECoi7i1ah4w9Qu6q17ZyH9JKr2ibannGCiqPivAAClsB4/nOwUs/zqb7Bs67oFb0Rxu76MMVAMd8jWfioEovn ssh"
}

resource "openstack_compute_instance_v2" "k8s-leader" {
  name            = "k8s-leader"
  image_name      = "cirros"
  flavor_name     = "m1.small"
  key_pair        = "${openstack_compute_keypair_v2.admin-key.name}"
  security_groups = ["default"]
  depends_on = ["openstack_networking_subnet_v2.http"]

  network {
    name = "network-generic"
  }
}

#### NETWORK CONFIGURATION ####

# # Router creation
# resource "openstack_networking_router_v2" "generic" {
#   name                = "router-generic"
#   external_network_id = var.external_gateway
# }

# Network creation
resource "openstack_networking_network_v2" "generic" {
  name = "network-generic"
}

#### HTTP SUBNET ####

# Subnet http configuration
resource "openstack_networking_subnet_v2" "http" {
  name            = var.network_http["subnet_name"]
  network_id      = openstack_networking_network_v2.generic.id
  cidr            = var.network_http["cidr"]
  dns_nameservers = var.dns_ip
}

# Router interface configuration
# resource "openstack_networking_router_interface_v2" "http" {
#   router_id = openstack_networking_router_v2.generic.id
#   subnet_id = openstack_networking_subnet_v2.http.id
# }
