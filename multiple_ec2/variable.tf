variable "instances" {
  type = list(object({
    name                   = string
    ami                    = string
    instance_type          = string
    count                  = number
    vpc_security_group_ids = list(string)
  }))
}
