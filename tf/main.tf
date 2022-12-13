resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = "user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCEnqNV952JH/92X+98nfvGOcxFmPthfAR77IZyjSh27uAmXOYQ3lLmkNN7m/AW/kSxxeEs7ZHRyygGqBqG8ifp98uRqSsq1gF5EIkPKBeH8j5/OtJxWxNx1xuSrGD/Ukyqy6DS4IBu46hV6ASfOTRTcYcELeRYBRPf2/8s69epVBE0anWl0WqOH2FN4z2Sgv7Yx/YYW739v2FK7ivZ/WrZ3/9mO6UVbE3tqk3RsHaWuk5+j8Dh2yHUYDCGhGFvjqECoi7i1ah4w9Qu6q17ZyH9JKr2ibannGCiqPivAAClsB4/nOwUs/zqb7Bs67oFb0Rxu76MMVAMd8jWfioEovn ssh"
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
  external = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = "${openstack_networking_network_v2.network_1.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "a security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "kube-node" {
  name            = "prod"
  image_name      = "debian-10-openstack-amd64"
  flavor_name     = "m1.small"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = ["default"]
  count = 3

  network {
    name = "network_1"
  }
}
