# resource "aws_instance" "test" {
#   ami           = "ami-06df38320cecdd700"
#   instance_type = "t2.micro"
#   count         = 2
#   vpc_security_group_ids = [
#     "sg-001427ab8e430e52d"
#   ]
# }

resource "aws_instance" "test" {
  for_each = {
    for k, v in var.instances : k => v if length(var.instances) != 0
  }
  ami           = each.value.ami
  instance_type = each.value.instance_type
  #   count                  = each.value.count
  vpc_security_group_ids = each.value.vpc_security_group_ids
}

# locals {
#   admin_users = {
#     for key, value in var.instances : key => value
#     if value.name == "test1"
#   }
# }

# output "test" {
#   value = local.admin_users
# }
