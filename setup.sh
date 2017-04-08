#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

apt-get install puppet-agent
puppet module install edestecd-software --version 1.1.0
puppet apply scripts/chrome.pp
puppet apply scripts/virtualbox.pp
puppet apply scripts/vagrant.pp
