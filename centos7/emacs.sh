#!/bin/bash

if ! (rpm -qa | grep ^emacs && rpm -qa | grep ^git) > /dev/null; then
    sudo yum -y install \
	emacs \
	git
fi

BASEDIR=~/.local/packages

mkdir -p $BASEDIR
pushd $BASEDIR > /dev/null

echo "Installing Emacs Solarized color scheme"
git clone https://github.com/sellout/emacs-color-theme-solarized

echo "Installing Emacs Chapel mode"
git clone https://github.com/russel/Emacs-Chapel-Mode

popd > /dev/null

cp ../.emacs ~/
