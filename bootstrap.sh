#!/bin/bash

#Fixes a bug that sets wrong permissions on /tmp 
chown root:root /tmp
chmod ugo+rwXt /tmp

#export DEBIAN_FRONTEND=noninteractive

#Updates base system
apt-get update && apt-get -y update


#the replace command installs with this package.  If it is not installed this script will fail 
#apt-get -y install mariadb-server


#Changes to correct naming in /etc/hosts
sed -i -- 's/127.0.0.1 ubuntu1804.localdomain//g' /etc/hosts
sed -i -- 's/ubuntu1804.localdomain/ubuntu1804.bmlt  ubuntu1804/g' /etc/hosts


#Change made to fix /etc/hostname to fix naming:
sed -i -- 's/ubuntu1804.localdomain/ubuntu1804/g' /etc/hostname

sudo hostname ubuntu1804
#Installs LAMP and some needed utilities
#apt-get -y install apache2 php libapache2-mod-php php-mysql php-cli openjdk-11-jdk git

#Installs some utilities
apt-get -y install locate wget net-tools curl vim

#Sets correct time and date, edit to reflect your timezone
sudo timedatectl set-timezone America/Chicago

#installs virtualmin
wget http://software.virtualmin.com/gpl/scripts/install.sh
sh ./install.sh -f -v

#Installs mail server for local only mail
#apt-get install -y postfix
#touch /home/vagrant/Mail
#apt-get -y install mutt mailutils

#sudo mail -s "Test Subject" vagrant@localhost < /dev/null

# installs Desktop Environment
apt-get -y install x-window-system ubuntu-minimal mousepad xarchiver synaptic

#Allows autologin to LXDE as vagrant
#sed -i -- 's/# autologin=dgod/autologin=vagrant/g' /etc/lxdm/lxdm.conf

#Adds Google Chrome web browser
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update && apt-get -y install google-chrome-stable

#Reboots system
reboot
