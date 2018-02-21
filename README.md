# Personal Rancher Server

This is my initial foray into running my own rancher server. Docker images for rancher-server and nginx are used to run and expose the rancher ui on a custom domain.

## To Use

### Pre-requisites:

- Terraform installed
- Digital Ocean account

1. Generate a new Digital Ocean API Key: [Guide Here:](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2#how-to-generate-a-personal-access-token)
2. Generate an SSH key pair on your local machine: `ssh-keygen -t rsa -f ~/.ssh/tmp_rancher_server`
3. Initialise Terraform: `terraform init`
3. Run the following command replacing with your details: `terraform plan -out=rancher_server.tfplan -var 'do_token=YOUR_DIGITAL_OCEAN_API_KEY' -var 'pub_key=/path/to/your/public/ssh_key.pub' -var 'pvt_key=/path/to/your/public/ssh_key' -var 'passwd=YOUR_USER_PASSWORD'`
4. If happy with the Terraform plan run: `terraform apply "rancher_server.tfplan"`
5. SSH into you new droplet: `ssh -i ~/.ssh/tmp_rancher_server root@NEW_DROPLET_IP`

Should you wish destroy your terraformed infrastructure simply run the command in step 3 above with the `-destroy` flag after `plan` and then re-run step 4 `apply`.

You'll need a linux box

- a linux box with `docker` and `docker-compose` installed.
- an SSL cert.
- a domain name with an A record pointing to the linux box.
- the `docker-compose.yml` and `rancher.conf` files from this repo on that box.







