terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = "dop_v1_005aae1a5e251245d3c8af6c9fc821f10b39dd393d7cd2190150f36376e4212d"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file("public_key.pub")
}

resource "digitalocean_droplet" "web" {
  name   = "TheSortex"
  region = "nyc1"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-20-04-x64"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  
}




resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  validity_period_hours = 8760  # Validez de 1 año

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "install_docker" {
  triggers = {
    droplet_id = digitalocean_droplet.web.id
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root" 
      private_key = file("public_key.pem")
      host        = digitalocean_droplet.web.ipv4_address
    }

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install git -y",
      #"sudo apt install nginx -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker root",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "git clone https://github.com/Zeroxite/laravel_app.git /home/root/terraform",
      "cd /home/root/terraform/",
      "sudo chmod 666 /var/run/docker.sock",
      "docker-compose up -d",
    ]
  }
}