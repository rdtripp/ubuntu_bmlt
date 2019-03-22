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

#/** MySQL database password */
sed -i -- 's/password_here/'"$PASSWD"'/g' /home/bmlt/public_html/wordpress/wp-config.php

#/**Configure WordPress Multisite**//
sed -i 's/.*Happy.*/define('MULTISITE', true);\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define('SUBDOMAIN_INSTALL', false);\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define('DOMAIN_CURRENT_SITE', '$DOMAIN');\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define('PATH_CURRENT_SITE', '/wordpress/');\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define('SITE_ID_CURRENT_SITE', 1);;\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define('BLOG_ID_CURRENT_SITE', 1);\n&/' /home/bmlt/public_html/wordpress/wp-config.php
sed -i 's/.*Happy.*/define( 'WP_ALLOW_MULTISITE', true );\n&/' /home/bmlt/public_html/wordpress/wp-config.php

#Configure .htaccess for wordpress multisite
#Clear contents of .htaccess
echo -n "" > .htaccess

#add new content to .htaccess

echo "# BEGIN WordPress" >> .htaccess 
echo "<IfModule mod_rewrite.c>" >> .htaccess
echo "RewriteEngine On" >> .htaccess
echo "RewriteBase /wordpress/" >> .htaccess
echo "RewriteRule ^index\.php$ - [L]" >> .htaccess

echo "# add a trailing slash to /wp-admin" >> .htaccess
echo "RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ $1wp-admin/ [R=301,L]" >> .htaccess

echo "RewriteCond %{REQUEST_FILENAME} -f [OR]" >> .htaccess
echo "RewriteCond %{REQUEST_FILENAME} -d" >> .htaccess
echo "RewriteRule ^ - [L]" >> .htaccess
echo "RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) $2 [L]" >> .htaccess
echo "RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ $2 [L]" >> .htaccess
echo "RewriteRule . index.php [L]" >> .htaccess

echo "</IfModule>" >> .htaccess

#End WordPress Install

#Set up system mail
apt-get -y install mutt mailutils
sudo mail -s "Test Subject" vagrant@localhost < /dev/null
sudo mail -s "Test Subject" $DOMAINUSER@localhost < /dev/null

# installs Desktop Environment
apt-get -y install x-window-system lxdm leafpad synaptic lxterminal

#Allows autologin to LXDE as $DOMAINUSER
sed -i -- 's/# autologin=dgod/autologin='"$DOMAINUSER"'/g' /etc/lxdm/lxdm.conf

#Adds Google Chrome web browser
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update && apt-get -y install google-chrome-stable

#Reboots system
reboot
