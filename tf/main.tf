# Create a new OpenStack network
resource "openstack_networking_network_v2" "k8s" {
  name = "k8s-network"
}

# Create a new OpenStack subnet
resource "openstack_networking_subnet_v2" "k8s" {
  network_id = openstack_networking_network_v2.k8s.id
  cidr       = "192.168.0.0/24"
  ip_version = 4
}

# Create a new OpenStack router
resource "openstack_networking_router_v2" "k8s" {
  name         = "k8s-router"
  external_gateway = "EXTERNAL_NETWORK_ID"
}

# Connect the router to the subnet
resource "openstack_networking_router_interface_v2" "k8s" {
  router_id = openstack_networking_router_v2.k8s.id
  subnet_id = openstack_networking_subnet_v2.k8s.id
}

# Create a new OpenStack security group
resource "openstack_compute_secgroup_v2" "k8s" {
  name        = "k8s-security-group"
  description = "k8s security group"

  # Allow SSH access
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# Create a new OpenStack key pair
resource "openstack_compute_keypair_v2" "k8s" {
  name      = "k8s-keypair"
  public_key = "PUBLIC_KEY"
}

# Create a new OpenStack instance
resource "openstack_compute_instance_v2" "k8s" {
  name            = "k8s-instance"
  security_groups = [openstack_compute_secgroup_v2.k8s.name]
  key_pair        = openstack_compute_keypair_v2.k8s.name
  flavor_name     = "FLAVOR_NAME"
  image_name      = "IMAGE_NAME"

  network {
    name = openstack_networking_network_v2.k8s.name
  }
}
