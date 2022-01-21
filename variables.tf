variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud Token (requires read & write permissions)"
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}
