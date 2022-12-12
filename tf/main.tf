resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = "user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCEnqNV952JH/92X+98nfvGOcxFmPthfAR77IZyjSh27uAmXOYQ3lLmkNN7m/AW/kSxxeEs7ZHRyygGqBqG8ifp98uRqSsq1gF5EIkPKBeH8j5/OtJxWxNx1xuSrGD/Ukyqy6DS4IBu46hV6ASfOTRTcYcELeRYBRPf2/8s69epVBE0anWl0WqOH2FN4z2Sgv7Yx/YYW739v2FK7ivZ/WrZ3/9mO6UVbE3tqk3RsHaWuk5+j8Dh2yHUYDCGhGFvjqECoi7i1ah4w9Qu6q17ZyH9JKr2ibannGCiqPivAAClsB4/nOwUs/zqb7Bs67oFb0Rxu76MMVAMd8jWfioEovn ssh"
}
