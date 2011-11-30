#!/bin/sh

name="vizr"
app_path=~/Library/WebServer/Document/${name}

echo "creating or updating app"
git clone git@github.com:howardr/vizr.git ${app_path}
cd ${app_path}
git pull

echo "installing dependencies and app"
rake install

echo "complete"
