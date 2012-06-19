#!/usr/bin/zsh
DOMAIN=gyazo.64p.org

if [ ! -f /etc/init/$DOMAIN.conf ]; then
    sudo ln -s `pwd`/etc/init/$DOMAIN.conf /etc/init/$DOMAIN.conf
fi

if [ ! -f /etc/nginx/sites-enabled/$DOMAIN.conf ]; then
    sudo ln -s `pwd`/etc/httpd/$DOMAIN.conf /etc/nginx/sites-enabled/$DOMAIN.conf
fi

sudo /etc/init.d/nginx reload
sudo initctl reload-configuration
sudo stop $DOMAIN
sudo start $DOMAIN

sudo chmod 777 ./var/

echo "--------------------------"
echo "Deployment finished"
sudo tail /var/log/upstart/$DOMAIN.log

