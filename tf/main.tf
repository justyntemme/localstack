# Replace external network ID with the correct value

# Ensure snap is installed with -devmode to enable volumes
# run 'sudo sysctl net.ipv4.ip_forward=1' on the host machine to ensure networks can connect
# As well as editing the external-network to be 'shared'
# always sudo ufw disable on host 

# Create a new OpenStack key pair

variable "cidr" {
  default = "0.0.0.0/0"
}

resource "openstack_compute_keypair_v2" "k8s-keypair" {
  name      = "k8s-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCEnqNV952JH/92X+98nfvGOcxFmPthfAR77IZyjSh27uAmXOYQ3lLmkNN7m/AW/kSxxeEs7ZHRyygGqBqG8ifp98uRqSsq1gF5EIkPKBeH8j5/OtJxWxNx1xuSrGD/Ukyqy6DS4IBu46hV6ASfOTRTcYcELeRYBRPf2/8s69epVBE0anWl0WqOH2FN4z2Sgv7Yx/YYW739v2FK7ivZ/WrZ3/9mO6UVbE3tqk3RsHaWuk5+j8Dh2yHUYDCGhGFvjqECoi7i1ah4w9Qu6q17ZyH9JKr2ibannGCiqPivAAClsB4/nOwUs/zqb7Bs67oFb0Rxu76MMVAMd8jWfioEovn ssh"
}

# Create a new OpenStack network
resource "openstack_networking_network_v2" "k8s-network" {
  name = "k8s-network"
  shared = true
}

# Create a new OpenStack floating IP
resource "openstack_compute_floatingip_v2" "k8s-fip" {
  pool = "external"
  count = 2
}

# Create a new OpenStack subnet
resource "openstack_networking_subnet_v2" "k8s-subnet" {
  network_id = openstack_networking_network_v2.k8s-network.id
  cidr       = "192.168.0.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "k8s-router-interface" {
  router_id = openstack_networking_router_v2.k8s-router.id
  subnet_id = openstack_networking_subnet_v2.k8s-subnet.id
}

# Create a new OpenStack router
resource "openstack_networking_router_v2" "k8s-router" {
  name         = "k8s-router"
  external_network_id = "a1827fa1-9fd3-4e63-bc1a-7adc41f008fa"
}

# Create a new OpenStack security group
resource "openstack_compute_secgroup_v2" "k8s-sec-group" {
  name        = "k8s-sec-group"
  description = "k8s security group"

  dynamic "rule" {
    for_each = [
      {
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
      },
      {
        from_port = 443
        to_port = 443
        ip_protocol = "tcp"
      },
      {
        from_port = 80
        to_port = 80
        ip_protocol = "tcp"
      },
      {
        from_port = 8080
        to_port = 8080
        ip_protocol = "tcp"
      },
      {
        from_port =30000
        to_port = 32767
        ip_protocol = "tcp"
      },
      {
        from_port = 10250
        to_port = 10250
        ip_protocol = "tcp"
      },
      {
        from_port = 500
        to_port = 500
        ip_protocol = "udp"
      },
      {
        from_port = 4500
        to_port = 4500
        ip_protocol = "udp"
      }
    ]

    content {
      from_port   = rule.value.from_port
      to_port     = rule.value.to_port
      ip_protocol = rule.value.ip_protocol
      cidr        = var.cidr
    }
  }
}

# Create the three instances
resource "openstack_compute_instance_v2" "k8s-node" {
  count = 2
  name = count.index == 0 ? "k8s-controller" : "k8s-node-${count.index}"
  flavor_name = "m1.medium"
  image_name      = "ubuntu-cloudimg-amd64"
  depends_on = [openstack_networking_subnet_v2.k8s-subnet]

  security_groups = [openstack_compute_secgroup_v2.k8s-sec-group.name]
  key_pair        = openstack_compute_keypair_v2.k8s-keypair.name

  network {
    uuid = openstack_networking_network_v2.k8s-network.id
    name = openstack_networking_network_v2.k8s-network.name
  }
  # floating_ip = element(openstack_compute_floatingip_v2.k8s-fip.*.address, count.index)
}

# Associate the floating IPs with the instances
resource "openstack_compute_floatingip_associate_v2" "associate-k8s-fip" {
  count = 2
  floating_ip = openstack_compute_floatingip_v2.k8s-fip[count.index].address
  instance_id = openstack_compute_instance_v2.k8s-node[count.index].id
}

# resource "openstack_blockstorage_volume_v3" "k8s-vol-1" {
#   region      = "microstack"
#   name        = "volume_1"
#   description = "k8s block storage"
#   size        = 5
# }