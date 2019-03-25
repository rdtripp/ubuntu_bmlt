This appliance was developed to be a quick way to deploy a local instance of multi-site WordPress, BMLT root server, and YAP for testing purposes.  This was developed from Ubuntu 18.04 and this project is in alpha.  User vagrant with password vagrant is the default for everything.  The root password is also vagrant.

This vagrant file takes a stock image and installs virtualmin, deploys a virtual server, and installs WordPress multisite.  Howto docs are in the works.
Requirements are Virtualbox 6.0 or later (virtualbox extensions are recommended) and vagrant 2.2.4 or later.
Vagrant vagrant-vbguest plugin is recommended. https://github.com/dotless-de/vagrant-vbguest
