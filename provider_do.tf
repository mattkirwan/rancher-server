variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "passwd" {}
variable "domain" {}
variable "email" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
