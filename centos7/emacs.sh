#!/bin/bash

set -e

yum -y install \
    emacs \
    git

BASEDIR=~/.local/packages

mkdir -p $BASEDIR
pushd $BASEDIR
git clone https://github.com/sellout/emacs-color-theme-solarized
git clone https://github.com/russel/Emacs-Chapel-Mode
popd

cp ../.emacs ~/
