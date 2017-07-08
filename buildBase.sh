#!/bin/bash
# Make sure only root can run our script
#if [ "$(id -u)" != "0" ]; then
#  echo "This script must be run as root" 1>&2
#  exit 1
#fi

[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$(whoami)"

set -e
user="$1"

if [ "$user" == "" ]; then
  echo "User not specified."
  exit 1
fi

# Install puppet, chrome, virtualbox, & vagrant
./scripts/setupPrereqs.sh

# Get packer
wget "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip"
unzip -o packer_1.0.0_linux_amd64.zip
rm packer_1.0.0_linux_amd64.zip

# Build Packer box.
name=BASE
if [ -f $name.box ]; then
  rm $name.box || true > /dev/null 2>&1
fi

pushd vm
sudo -H -u $user bash -c 'packer build -only virtualbox-iso BASE.json'
#packer build -only virtualbox-iso $name.json
popd

vagrant box remove $name || true > /dev/null 2>&1
vagrant box add $name vm/$name.box
rm vm/$name.box > /dev/null 2>&1
#sudo chown -R $me:$me .vagrant
sudo chown -R $user:$user packer
sudo chown -R $user:$user .vagrant
