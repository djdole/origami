#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

rm -f packer
rm -f packer*.zip
rm -f vm/*.box
rm -rf vm/packer_cache
rm -rf .vagrant
sudo vagrant box remove BLANK
