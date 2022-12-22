# Create a new OpenStack network
resource "openstack_networking_network_v2" "k8s" {
  name = "k8s-network"
}

# Create a new OpenStack floating IP
resource "openstack_compute_floatingip_v2" "example" {
  pool = "external"
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
  external_network_id = "f9690377-d6a7-45b4-bd9a-82e728383cfb"
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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCEnqNV952JH/92X+98nfvGOcxFmPthfAR77IZyjSh27uAmXOYQ3lLmkNN7m/AW/kSxxeEs7ZHRyygGqBqG8ifp98uRqSsq1gF5EIkPKBeH8j5/OtJxWxNx1xuSrGD/Ukyqy6DS4IBu46hV6ASfOTRTcYcELeRYBRPf2/8s69epVBE0anWl0WqOH2FN4z2Sgv7Yx/YYW739v2FK7ivZ/WrZ3/9mO6UVbE3tqk3RsHaWuk5+j8Dh2yHUYDCGhGFvjqECoi7i1ah4w9Qu6q17ZyH9JKr2ibannGCiqPivAAClsB4/nOwUs/zqb7Bs67oFb0Rxu76MMVAMd8jWfioEovn ssh"
}

# Create a new OpenStack instance for kubeadmin
resource "openstack_compute_instance_v2" "kube-node"{
  name            = "k8s-instance-${count.index}"
  count = 2
  security_groups = [openstack_compute_secgroup_v2.k8s.name]
  key_pair        = openstack_compute_keypair_v2.k8s.name
  flavor_name     = "m1.medium"
  image_name      = "ubuntu-cloudimg-amd64"

  network {
    name = openstack_networking_network_v2.k8s.name
  }
}

# Create a new OpenStack instance
resource "openstack_compute_instance_v2" "k8s-controller" {
  name            = "k8s-controller"
  security_groups = [openstack_compute_secgroup_v2.k8s.name]
  key_pair        = openstack_compute_keypair_v2.k8s.name
  flavor_name     = "m1.medium"
  image_name      = "ubuntu-cloudimg-amd64"

  network {
    name = openstack_networking_network_v2.k8s.name
  }

  # Associate a floating IP with the instance
  floating_ip = openstack_compute_floatingip_v2.example.address
}
