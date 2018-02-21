resource "digitalocean_ssh_key" "rancher_server_ssh_key" {
    name = "Rancher SSH Key"
    public_key = "${file(var.pub_key)}"
}

resource "digitalocean_droplet" "rancher_server_droplet" {
    
    image  = "ubuntu-16-04-x64"
    name   = "rancher-server"
    region = "nyc1"
    size   = "512mb"
    ssh_keys = ["${digitalocean_ssh_key.rancher_server_ssh_key.fingerprint}"]
    
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
            "ufw allow https",
            "yes | ufw enable",
            "apt-get -y install docker",
            "apt-get -y install docker-compose",
            "mkdir /opt/rancher",
            "chown rancher: /opt/rancher",
            "apt-get -y install software-properties-common",
            "add-apt-repository -y ppa:certbot/certbot",
            "apt-get -y update",
            "apt-get -y install python-certbot-nginx",
            "ufw allow http",
            # Need to create this after full provision
            # "certbot --nginx certonly --email dsjh64@bestmail.us -d dsjh64.net --agree-tos --no-eff-email",
            "ufw delete allow http",
        ]
    }

    provisioner "file" {
        source      = "./rancher.conf"
        destination = "/opt/rancher/rancher.conf"
    }

}

resource "digitalocean_floating_ip" "rancher_server_ip" {
    droplet_id = "${digitalocean_droplet.rancher_server_droplet.id}"
    region = "${digitalocean_droplet.rancher_server_droplet.region}"
}

resource "digitalocean_domain" "rancher_server_domain" {
    name       = "dsjh64.net"
    ip_address = "${digitalocean_floating_ip.rancher_server_ip.ip_address}"
}