#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

# Install puppet, chrome, virtualbox, & vagrant
apt-get install puppet-agent
puppet module install edestecd-software --version 1.1.0
puppet apply scripts/chrome.pp
puppet apply scripts/virtualbox.pp
puppet apply scripts/vagrant.pp

# Get packer
#https://releases.hashicorp.com/packer/1.0.0/
wget https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip
unzip packer_1.0.0_linux_amd64.zip
rm packer_1.0.0_linux_amd64.zip

# Build Packer box.
name=BLANK
rm $name.box || true
pushd vm
packer build -only virtualbox-iso $name.json
popd
vagrant box remove $name || true
vagrant box add $name vm/$name.box
rm vm/$name.box
