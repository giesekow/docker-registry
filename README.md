# Private docker registry with frontend UI

## Requirements
1. docker
2. docker-compose
3. text editor e.g. `vim`, `gedit`, etc.

Example installation on ubuntu 20.04 `sudo apt-get install -y docker.io docker-compose vim`


## Required information
1. Domain name for the registry e.g. `registry.example.com`.
2. Domain name for the frontend e.g. `ui.registry.example.com`.
3. Email for settings up letsencrypt in case you want to use SSL connection with you domain. This is handled automatically and requires external domains. e.g. `certs@example.com`.
4. 

## Installation on Ubuntu 18.04 and above.
To setup the service on ubuntu run `bash install.sh` and follow the prompt. You will be asked to entry the required information above.

## Setup manually
To setup manually without the install script:
1. Make a copy of `.env-template` as `.env` and make the following changes to the new `.env` file
  * replace `<REGISTRY_DOMAIN_NAME>` by the registry domain name see example above
  * replace `<FRONTEND_DOMAIN_NAME>` by the frontend domain name see example above
  * replace `<LE_EMAIL>` by the email address for setup SSL by letsencrypt.
  * replace `<IS_SSL>` by `yes` or `no` to issue SSL certs or not.

2. Make a copy of `sites-available/app` as `sites-enabled/app` and make the following changes to `sites-enabled/app`
  * replace `<REGISTRY_DOMAIN_NAME>` by the registry domain name see example above
  * replace `<FRONTEND_DOMAIN_NAME>` by the frontend domain name see example above

3. Make a copy of `credentials-template.yml` as `credentials.yml` and make the following changes to `credentials.yml`
  * replace `<FRONTEND_DOMAIN_NAME>` by the frontend domain name see example above
  * replace `<PROTO>` by `http` if you are NOT using SSL,  or `https` if you are using SSL.

4. Make credientials for securing the registry as follows
  * We will use the `htpasswd` tool from apache to generate the credentials: install if not already available `sudo apt install apache2-utils`
  * Generate the first user credential with `htpasswd -Bc ./auth/registry.password <user_name>` replace `<user_name>` with your preferred username.
  * You can generate additional credentials with `htpasswd -B ./auth/registry.password <another_user_name>`. Note here we ignore the `-c` switch which creates a new file.

5. Start the docker containers by running `docker-compose up` or use the start script `sh start.sh`.

6. Stop the docker containers by running `docker-compose down` or use the stop script `sh stop.sh`.

7. (Optional) To setup systemd to start the service automatically on system boot.
  * Edit `docker-registry.service` file and replace `$WORKDIR` with the absolute path of the cloned repository.
  * Copy the `docker-registry.service` file to the systemd services folder. On Ubuntu this is `/etc/systemd/system/` or `/lib/systemd/system/`
  * Start the service with `systemctl start docker-registry`. You might need to use `sudo`.
  * Enable autostart after reboot with `systemctl enable docker-registry`. You might need `sudo` here as well.


## Adding more user accounts
1. We will use the `htpasswd` tool from apache to generate the credentials: install if not already available `sudo apt install apache2-utils`
2. You can generate additional credentials with `htpasswd -B ./auth/registry.password <another_user_name>`. Replace `another_user_name` with the new username.