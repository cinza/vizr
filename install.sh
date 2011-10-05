#!/bin/sh

name="vizr"
app_path=~/code/${name}

echo "creating directory ${app_path}"
mkdir -p ${app_path} &> ${app_path}/install.log

echo "creating or updating app"
git clone git@github.com:howardr/vizr.git ${app_path} &> ${app_path}/install.log
cd ${app_path}
git pull &> ${app_path}/install.log

echo "installing dependencies and app"
rake install &> ${app_path}/install.log

echo "complete"
