#!/bin/bash
#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

#Updates base system
apt-get update && apt-get -y update

#Configure swap file
dd if=/dev/zero of=/swapfile bs=2048 count=2097152
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "vm.swappiness=10" >> /etc/sysctl.conf 

#Get user input 
read -p "Enter FQDN for Virtual Server:   "  DOMAIN
read -p "Enter Password for Virtual Server:   "  PASSWD
read -p "Enter Admin User for WordPress:   " WPADMIN
read -p "Enter WordPress Admin User Password:   " WPADMINPASS
read -p "Enter WordPress Default Site Name:   " WPSITENAME
 
#Sets correct time and date, edit to reflect your timezone
sudo timedatectl set-timezone America/Chicago

#Starts Virtualmin install
#Downloads Virtualmin install script
wget http://software.virtualmin.com/gpl/scripts/install.sh

#Installs full Virtualmin
#sh ./install.sh -f -v

#Installs Virtualmin Minimum (default)
sh ./install.sh -f -v -m
#End Virtualmin Install

#Start virtual domain install
#Set virtual domain, virtual domain user, and virtual domain password
#DOMAIN="vagrant.vagrant.bmlt"
DOMAINUSER=`echo "$DOMAIN" | cut -d'.' -f 1`
#PASSWD="PASSWORD"

virtualmin create-domain --domain $DOMAIN --pass $PASSWD --desc "BMLT DEV" --unix --dir --webmin  --web --ssl --mysql --dns --mail --limits-from-plan

#End virtual domain install

#Start WordPress Install
#set wordpress database name
WPDB="wp_$DOMAINUSER"
# create database for wordpress
virtualmin create-database --domain $DOMAIN --name $WPDB --type mysql

#Install WordPress
virtualmin install-script --domain $DOMAIN --type wordpress --version latest --path / --db mysql $WPDB

#Confiure mysql database access in wp-config.php

#/** The name of the database for WordPress */
 sed -i -- 's/database_name_here/'"$WPDB"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

# /** MySQL database username */
sed -i -- 's/username_here/'"$DOMAINUSER"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

#/** MySQL database password */
sed -i -- 's/password_here/'"$PASSWD"'/g' /home/"$DOMAINUSER"/public_html/wp-config.php

#End WordPress Install

#Install Wordpress CLI
apt-get update && apt-get -y install curl
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
#End Wordpress CLI install

#Configure WordPress multisite
#WPADMIN="admin"
#WPADMINPASS="PASSWORD"
#WPSITENAME="DO Test"
sudo -u $DOMAINUSER wp core multisite-install --path=/home/"$DOMAINUSER"/public_html/ --url=http://"$DOMAIN"/ --title="$WPSITENAME" --admin_user=$WPADMIN --admin_password=$WPADMINPASS --admin_email=$DOMAINUSER@$DOMAIN
wget -cO - https://raw.githubusercontent.com/rdtripp/ubuntu_bmlt/nox/htaccess >  /home/"$DOMAINUSER"/public_html/.htaccess

#install WordPress Plugins
sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html plugin install bmlt-wordpress-satellite-plugin --activate-network
sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html plugin install bread --activate-network
sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html plugin install crouton --activate-network
sudo -u "$DOMAINUSER" -i -- wp --path=/home/"$DOMAINUSER"/public_html plugin install bmlt-tabbed-map --activate-network

#Updates system to reflect new sources added by installs
apt-get update && apt-get -y update

#set yap database name
YAPDB="yap_$DOMAINUSER"
#create database for wordpress
virtualmin create-database --domain $DOMAIN --name $YAPDB --type mysql
#Get YAP
cd /home/"$DOMAINUSER"/public_html/
wget https://github.com/bmlt-enabled/yap/archive/master.zip 
unzip master.zip
mv ./yap* ./yap
chown "$DOMAINUSER":"$DOMAINUSER" ./yap
#Reboot system
#reboot

