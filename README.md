This appliance was developed to be a quick way to deploy a local instance of multi-site WordPress, BMLT root server, and YAP for testing purposes.  This was developed from Debian testing “buster” and this project is in alpha.  User vagrant with password vagrant is the default for everything.  The root password is also vagrant.

Apache document root is ~/public_html and it is running under user:group of vagrant:vagrant and listening on ports 80, 443, and 444.  WordPress is configured multi-site and additional sites can be easily deployed. 

Requirements are Virtualbox 6.0 or later (virtualbox extensions are recommended) and vagrant 2.2.4 or later.
