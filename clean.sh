#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

sudo rm -f packer > /dev/null 2>&1
sudo rm -f packer*.zip > /dev/null 2>&1
sudo vagrant destroy -f > /dev/null 2>&1
sudo rm -f vm/*.box > /dev/null 2>&1
sudo rm -rf vm/packer_cache > /dev/null 2>&1
sudo rm -rf .vagrant > /dev/null 2>&1
sudo vagrant box remove BASE -f > /dev/null 2>&1
