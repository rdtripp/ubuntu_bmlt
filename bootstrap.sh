#!/bin/bash

#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

#Updates base system
apt-get update && apt-get -y update

#Sets correct time and date, edit to reflect your timezone
sudo timedatectl set-timezone America/Chicago

#Changes to correct naming in /etc/hosts
sed -i -- 's/127.0.0.1 ubuntu1804.localdomain//g' /etc/hosts
sed -i -- 's/ubuntu1804.localdomain/ubuntu1804.bmlt  ubuntu1804/g' /etc/hosts

#Changes made in /etc/hostname to fix naming:
sed -i -- 's/ubuntu1804.localdomain/ubuntu1804/g' /etc/hostname
sudo hostname ubuntu1804

#Starts Virtualmin install
#Downloads Virtualmin install script
wget http://software.virtualmin.com/gpl/scripts/install.sh

#Installs full Virtualmin
sh ./install.sh -f -v

#Installs Virtualmin Minimum (default)
#sh ./install.sh -f -v -m
#End Virtualmin Install

#Start virtual domain install
#Set virtual domain, virtual domain user, and virtual domain password
DOMAIN="bmlt.bmlt"
DOMAINUSER=${DOMAIN#*.}
PASSWD="bmlt"

virtualmin create-domain --domain $DOMAIN --pass $PASSWD --desc "BMLT DEV" --unix --dir --webmin  --web --ssl --mysql --dns --mail --limits-from-plan

#append "127.0.1.2" $DOMAIN to /etc/hosts
echo "" >> /etc/hosts
echo "#Added by bootstrap.sh" >> /etc/hosts
echo "127.0.1.2 " $DOMAIN >> /etc/hosts

#Set private IP address for virtual domain
virtualmin modify-domain --domain $DOMAIN --ip-already 127.0.1.2 

#End virtual domain install

#Start WordPress Install
#set wordpress database name
WPDB="wp_bmlt"
# create database for wordpress
virtualmin create-database --domain $DOMAIN --name $WPDB --type mysql

#Install WordPress
virtualmin install-script --domain $DOMAIN --type wordpress --version latest --path /wordpress --db mysql $WPDB

#Confiure mysql database access in wp-config.php

#/** The name of the database for WordPress */
 sed -i -- 's/database_name_here/'"$WPDB"'/g' /home/bmlt/public_html/wordpress/wp-config.php

# /** MySQL database username */
sed -i -- 's/username_here/'"$DOMAINUSER"'/g' /home/bmlt/public_html/wordpress/wp-config.php

/** MySQL database password */
sed -i -- 's/password_here/'"$PASSWD"'/g' /home/bmlt/public_html/wordpress/wp-config.php

#End WordPress Install


# installs Desktop Environment
apt-get -y install x-window-system lxdm leafpad synaptic lxterminal mutt

#Allows autologin to LXDE as $DOMAINUSER
sed -i -- 's/# autologin=dgod/autologin='"$DOMAINUSER"'/g' /etc/lxdm/lxdm.conf

#Adds Google Chrome web browser
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update && apt-get -y install google-chrome-stable

#Reboots system
reboot
