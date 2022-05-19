#!/bin/sh

echo "Enter domain name for registry:"
read REGISTRY_DOMAIN_NAME
echo "Enter domain name for frontend:"
read FRONTEND_DOMAIN_NAME
echo "Enable ssl on domains ? (y/N):"
read SSL

PROTO=http
SSLREQ=no
EMAIL=certs@example.com

if [ "$SSL" = "y" ] || [ "$SSL" = "Y" ]
then
  SSLREQ=yes
  PROTO=https
  echo "Enter email for letsencrypt certificate server:"
  read LE_EMAIL
  EMAIL=$LE_EMAIL
fi

if [ -z $REGISTRY_DOMAIN_NAME ] || [ -z $FRONTEND_DOMAIN_NAME ]
then
    echo "registry and frontend domain names required"
else
  cp .env-template .env
  sed -i "s%<FRONTEND_DOMAIN_NAME>%$FRONTEND_DOMAIN_NAME%g" .env
  sed -i "s%<REGISTRY_DOMAIN_NAME>%$REGISTRY_DOMAIN_NAME%g" .env
  sed -i "s%<LE_EMAIL>%$EMAIL%g" .env
  sed -i "s%<IS_SSL>%$SSLREQ%g" .env

  cp credentials-template.yml credentials.yml
  sed -i "s%<FRONTEND_DOMAIN_NAME>%$FRONTEND_DOMAIN_NAME%g" credentials.yml
  sed -i "s%<PROTO>%$PROTO%g" credentials.yml

  mkdir -p sites-enabled
  cp sites-available/app sites-enabled/app
  sed -i "s%<FRONTEND_DOMAIN_NAME>%$FRONTEND_DOMAIN_NAME%g" sites-enabled/app
  sed -i "s%<REGISTRY_DOMAIN_NAME>%$REGISTRY_DOMAIN_NAME%g" sites-enabled/app

  chmod +x start.sh
  chmod +x stop.sh

  sudo apt install apache2-utils
  mkdir -p auth
  echo "Enter Username for accessing the registry"
  read user_name
  htpasswd -Bc ./auth/registry.password $user_name

  echo "Configure systemd service to start at system reboot ? (y/N):"
  read CONF_SYSTEMD


  if [ "$CONF_SYSTEMD" = "y" ] || [ "$CONF_SYSTEMD" = "Y" ]
  then
    sed -i "s%\$WORKDIR%$(pwd)%g" docker-registry.service
    sudo cp docker-registry.service /etc/systemd/system/
    sudo systemctl start docker-registry
    sudo systemctl enable docker-registry
  fi

fi
