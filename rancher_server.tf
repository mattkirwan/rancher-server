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
    
    connection {
        user = "root"
        type = "ssh"
        private_key = "${file(var.pvt_key)}"
        timeout = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "apt-get -y update",
            "apt-get -y upgrade",
            "adduser rancher --gecos '' --quiet --disabled-login --shell /bin/bash --disabled-password",
            "usermod -aG sudo rancher",
            "echo rancher:${var.passwd} | chpasswd",
            "mkdir /home/rancher/.ssh",
            "chown rancher: /home/rancher/.ssh",
            "chmod 0700 /home/rancher/.ssh",
            "cp /root/.ssh/authorized_keys /home/rancher/.ssh/",
            "chown rancher: /home/rancher/.ssh/authorized_keys",
            "ufw allow OpenSSH",
            "yes | ufw enable",
            "apt-get -y install docker",
            "apt-get -y install docker-compose",
        ]
    }


}