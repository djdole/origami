#!/bin/bash

set -e

LOC="vm"
NOM=BLANK

#export PACKER_LOG=1
rm $NOM.box || true
pushd $LOC
packer build -only virtualbox-iso $NOM.json
popd

vagrant box remove $NOM || true
vagrant box add $NOM $LOC/$NOM.box
rm $LOC/$NOM.box
