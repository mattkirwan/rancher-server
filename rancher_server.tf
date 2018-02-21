resource "digitalocean_ssh_key" "rancher" {
    name = "Rancher SSH Key"
    public_key = "${file(var.pub_key)}"
}

resource "digitalocean_droplet" "rancher" {
    image  = "ubuntu-16-04-x64"
    name   = "rancher-test"
    region = "nyc1"
    size   = "512mb"
    ssh_keys = ["${digitalocean_ssh_key.rancher.fingerprint}"]
}