variable "users" {
  type = list(object({
    name = string
    age = number
  }))
}

variable "users_test" {
  type = list(object({
    name = string
    age = number
    address = object({
      city = string
      code = number
    })
  }))
}

