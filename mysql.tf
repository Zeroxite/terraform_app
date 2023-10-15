resource "digitalocean_droplet" "mysql" {
  image    = "ubuntu-20-04-x64"
  name     = "mysql"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  user_data = <<-EOF
    #cloud-config
    runcmd:
      - set -o errexit
      - sudo apt-get update -y
      - sudo apt-get install git -y
      - sudo apt-get install docker.io -y
      - sudo systemctl start docker
      - sudo usermod -aG docker root
      - git clone https://github.com/Zeroxite/mysql.git /home/root/mysql
      - cd /home/root/mysql/
      - sudo chmod 666 /var/run/docker.sock
      - docker-compose up -d
  EOF
}