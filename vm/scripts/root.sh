#!/bin/bash

set -e

echo "Updating and Upgrading dependencies..."
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

echo "Install necessary libraries for guest additions and Vagrant NFS Share..."
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common

echo "Install necessary dependencies..."
sudo apt-get -y -q install curl wget git tmux firefox xvfb vim

echo "Setup sudo to allow no-password sudo for 'admin'..."
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

echo "INSTALLING Puppet..."
echo "================================================================="
url="http://apt.puppetlabs.com/puppetlabs-release-pc1-yakkety.deb"
echo "Downloading $url..."
sudo wget -O puppet.deb "$url"
echo "Installing..."
sudo dpkg --force-depends -i puppet.deb
sudo apt-get update
sudo rm -f puppet.deb
echo "================================================================="

# Allow Apache in the firewall, if it isn't...
#sudo ufw allow in "Apache Full"
#sudo systemctl restart apache2

#echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

#cd /var/www/html

#git clone https://github.com/docusign/recipe-010-webhook-php.git
#echo "<?php header("Location: recipe-010-webhook-php/web/010.webhook.php"); ?>" > /var/www/html/Heroku.php

#git clone https://github.com/docusign/docusign-soap-sdk.git
#echo "<?php header("Location: docusign-soap-sdk/PHP/Connect/index.php"); ?>" > /var/www/html/SOAP.php
#echo "<?php header("Location: docusign-soap-sdk/PHP/Connect/index.php"); ?>" > /var/www/html/index.php

#Install Mono
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
#echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
#sudo apt-get update
#sudo apt-get -y -q install mono-complete

#echo '#!/bin/bash' > /home/vagrant/mountWWWROOT.sh
#echo "mount -t vboxsf -o uid=1000,gid=1000 wwwroot /wwwroot" >> /home/vagrant/mountWWWROOT.sh
#chmod u+x /home/vagrant/mountWWWROOT.sh
#chown vagrant:vagrant /home/vagrant/mountWWWROOT.sh

#Install VirtualBox Guest Additions
#VBoxVersion="5.1.20"
#echo "Install VirtualBox Guest Additions..."
#wget http://download.virtualbox.org/virtualbox/$VBoxVersion/VBoxGuestAdditions_$VBoxVersion.iso
#sudo mkdir -f /media/VBoxGuestAdditions
#sudo mount -o loop,ro VBoxGuestAdditions_$VBoxVersion.iso /media/VBoxGuestAdditions
#sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
#rm VBoxGuestAdditions_$VBoxVersion.iso
#sudo umount /media/VBoxGuestAdditions
#sudo rmdir /media/VBoxGuestAdditions
#echo "VBox guest additions installed!"
