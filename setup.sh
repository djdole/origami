#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

apt-get install puppet-agent
./scripts/edestecd-software.puppet
puppet apply scripts/chrome.pp
puppet apply scripts/virtualbox.pp
puppet apply scripts/vagrant.pp
