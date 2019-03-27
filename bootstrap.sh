#!/bin/bash

#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

#Updates base system
apt-get update && apt-get -y update

#Sets correct time and date, edit to reflect your timezone
sudo timedatectl set-timezone America/Chicago

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
sudo virtualmin modify-domain --domain $DOMAIN --shared-ip 127.0.1.2 

#End virtual domain install

#Start WordPress Install
#set wordpress database name
WPDB="wp_bmlt"
# create database for wordpress
virtualmin create-database --domain $DOMAIN --name $WPDB --type mysql

#Install WordPress
virtualmin install-script --domain $DOMAIN --type wordpress --version latest --path / --db mysql $WPDB

#Confiure mysql database access in wp-config.php

#/** The name of the database for WordPress */
 sed -i -- 's/database_name_here/'"$WPDB"'/g' /home/bmlt/public_html/wp-config.php

# /** MySQL database username */
sed -i -- 's/username_here/'"$DOMAINUSER"'/g' /home/bmlt/public_html/wp-config.php

#/** MySQL database password */
sed -i -- 's/password_here/'"$PASSWD"'/g' /home/bmlt/public_html/wp-config.php

#End WordPress Install

#Install Wordpress CLI
apt-get update && apt-get -y install curl
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
#End Wordpress CLI install

#Configure WordPress multisite
WPADMIN="admin"
WPADMINPASS="PASSWORD"
WPSITENAME="BMLT TEST"
sudo -u $DOMAINUSER wp core multisite-install --path=/home/$DOMAINUSER/public_html/ --url=http://$DOMAIN/ --title="$WPSITENAME" --admin_user=$WPADMIN --admin_password=$WPADMINPASS --admin_email=$DOMAINUSER@$DOMAIN
sudo -u $DOMAINUSER cp /vagrant/htaccess /home/$DOMAINUSER/public_html/.htaccess
# installs Desktop Environment
apt-get -y install x-window-system lxdm leafpad synaptic lxterminal mutt

#Allows autologin to LXDE as $DOMAINUSER
sed -i -- 's/# autologin=dgod/autologin='"$DOMAINUSER"'/g' /etc/lxdm/lxdm.conf

#Adds Google Chrome web browser
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update && apt-get -y install google-chrome-stable

#Launches Google Chrome on default user login (testing file operations from vagrant)
cp /usr/share/applications/google-chrome.desktop /etc/xdg/autostart/.
sed -i -- 's+Exec=/usr/bin/google-chrome-stable %U+Exec=/usr/bin/google-chrome-stable %U  https://'$DOMAIN+'g' /etc/xdg/autostart/google-chrome.desktop
#Reboots system
reboot
