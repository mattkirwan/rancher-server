# Personal Rancher Server

This is my initial foray into running my own rancher server. I wanted to expose myself to some new tools and end up with something useful for personal projects going forward.

## What does this repo do?

This repo uses [Terraform](https://www.terraform.io/) to provision a [Rancher Server](https://rancher.com/) in [Digital Ocean](https://www.digitalocean.com/) with two commands.

The Rancher Server is powered by the stable Rancher [Docker](https://www.docker.com/) image and is reverse proxied by the stable [Nginx](https://nginx.org/) docker image.

## Pre-requisites

- Terraform installed
- Digital Ocean account

## Usage

Clone the repo and run a `terraform plan` and `apply` with the following variables.

### Terraform Variables



- `do_token` - Your Digital Ocean API token ([How-to](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2#how-to-generate-a-personal-access-token)).
- `pub_key` - The local path to an ssh public key that will be used by terraform to ssh into your new droplet.
- `pvt_key` - The local path to a matching ssh private key that will be used by terraform to ssh into your new droplet.
- `passwd` - The password you would like to set for `sudo` access for the `rancher` user created by terraform.
- `domain` - The public domain name which you would like to access your rancher server.
- `email` - The email address you would like associated with the [Let's Enrypt](https://letsencrypt.org/) SSL certificate.


### Example Usage

- ```
    git clone git@github.com:mattkirwan/rancher-server.git
    
    cd rancher-server
    
    terraform init
    
    ssh-keygen -t rsa -f ~/.ssh/my_rancher_server
    
    terraform plan -out=rancher_server.tfplan \
    -var 'do_token=YOUR_DO_TOKEN' \
    -var 'pub_key=/Users/yourhome/.ssh/my_rancher_server.pub' \
    -var 'pvt_key=/Users/yourhome/.ssh/my_rancher_server'
    -var 'passwd=YOUR_TOPSECRET_PASSWORD' \
    -var 'domain=your-rancher-server.net' \
    -var 'email=your.email.address@for.ssl.cert'
    
    terraform apply rancher_server.tfplan
    ssh -i ~/.ssh/tmp_rancher_server rancher@NEW_DROPLET_IP
    ```

Should you wish to destroy your rancher server just add the `-destroy` flag to the `terraform plan` and then `apply` the updated plan.

## Todo







