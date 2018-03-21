data "template_file" "rancher_conf" {
  template = "${file("./tpl/rancher.conf.tpl")}"

  vars {
    domain = "${var.domain}"
  }
}

resource "null_resource" "export_rendered_rancher_template" {
  provisioner "local-exec" {
    command = "cat > ./conf/rancher.conf <<EOL\n${data.template_file.rancher_conf.rendered}\nEOL"
  }
}

resource "digitalocean_ssh_key" "rancher_server_ssh_key" {
  name       = "Rancher SSH Key"
  public_key = "${file(var.pub_key)}"
}

resource "digitalocean_droplet" "rancher_server_droplet" {
  image    = "ubuntu-16-04-x64"
  name     = "${var.domain}"
  region   = "ams3"
  size     = "1gb"
  ssh_keys = ["${digitalocean_ssh_key.rancher_server_ssh_key.fingerprint}"]

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout     = "2m"
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
      "apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get -y update",
      "apt-get -y install docker-ce",
      "apt-get -y install docker-compose",
      "mkdir /opt/rancher",
      "chown rancher: /opt/rancher",
    ]
  }

  provisioner "file" {
    source      = "./conf/nginx.conf"
    destination = "/opt/rancher/nginx.conf"
  }

  provisioner "file" {
    source      = "./conf/rancher.conf"
    destination = "/opt/rancher/rancher.conf"
  }

  provisioner "file" {
    source      = "./docker-compose.yml"
    destination = "/opt/rancher/docker-compose.yml"
  }
}

resource "digitalocean_floating_ip" "rancher_server_ip" {
  droplet_id = "${digitalocean_droplet.rancher_server_droplet.id}"
  region     = "${digitalocean_droplet.rancher_server_droplet.region}"
}

resource "digitalocean_domain" "rancher_server_domain" {
  name       = "${var.domain}"
  ip_address = "${digitalocean_floating_ip.rancher_server_ip.ip_address}"
}

resource "null_resource" "install_cert" {
  connection {
    host        = "${digitalocean_floating_ip.rancher_server_ip.ip_address}"
    user        = "root"
    type        = "ssh"
    agent       = true
    private_key = "${file(var.pvt_key)}"
    timeout     = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get -y install software-properties-common",
      "add-apt-repository -y ppa:certbot/certbot",
      "apt-get -y update",
      "apt-get -y install certbot",
      "ufw allow http",
      "certbot certonly --email ${var.email} -d ${var.domain} --agree-tos --no-eff-email --standalone",
      "ufw delete allow http",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f /opt/rancher/docker-compose.yml up -d web_server",
    ]
  }
}
