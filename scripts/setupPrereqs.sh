#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

set -e

if ! hash vboxmanage 2>/dev/null; then
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    if [[ ${ID} = ubuntu ]]; then
      codename=$(lsb_release -cd | grep Codename) 
      prefix="Codename:	"
      codename=${codename#$prefix}
      version="5.1"
      subversion=".22"
      build="115126"
      host="http://download.virtualbox.org/virtualbox/${version}${subversion}/"
      file="virtualbox-${version}_${version}${subversion}-${build}~Ubuntu~${codename}_amd64.deb"
      url=${host}${file}
      echo "Downloading virtualbox ${version}${subversion}..."
      wget ${url}
      echo "Installing..."
      dpkg -i ${file}
      rm ${file}
    else
      echo "Not running an Ubuntu distribution. ID=${ID}, VERSION=${VERSION}"
    fi
  else
    echo "Not running a distribution with /etc/os-release available"
  fi
fi

# Install puppet, chrome, virtualbox, & vagrant
sudo apt-get install puppet-agent
#puppet module install edestecd-software --version 1.1.0
#puppet apply scripts/virtualbox.pp
#puppet apply scripts/vagrant.pp

if ! hash vagrant 2>/dev/null; then
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    if [[ ${ID} = ubuntu ]]; then
#      version="1.9.4"
      version="1.8.4"
      host="https://releases.hashicorp.com/vagrant/${version}/"
      file="vagrant_${version}_x86_64.deb"
      url=${host}${file}
#      url="https://releases.hashicorp.com/vagrant/1.9.4/vagrant_1.9.4_x86_64.deb?_ga=2.45359277.802931467.1494838094-1814000029.1489988185"
      echo "Downloading vagrant ${version}..."
      wget -O vagrant.deb ${url}
      echo "Installing..."
      dpkg -i vagrant.deb
      rm vagrant.deb
    else
      echo "Not running an Ubuntu distribution. ID=${ID}, VERSION=${VERSION}"
    fi
  else
    echo "Not running a distribution with /etc/os-release available"
  fi
fi

