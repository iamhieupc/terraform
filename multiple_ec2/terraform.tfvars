instances = [
  {
    name                   = "test1"
    ami                    = "ami-06df38320cecdd700",
    instance_type          = "t2.micro",
    count                  = 1,
    vpc_security_group_ids = ["sg-001427ab8e430e52d"]
  },
  {
    name                   = "test2"
    ami                    = "ami-06df38320cecdd700",
    instance_type          = "t2.micro",
    count                  = 1,
    vpc_security_group_ids = ["sg-001427ab8e430e52d"]
  },
]
