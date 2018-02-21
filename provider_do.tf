variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "passwd" {}

provider "digitalocean" {
    token = "${var.do_token}"
}