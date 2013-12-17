#!/bin/bash

###----------------------------------------###
###
###  Exea Media Player Installer
###
###  Copyright (C) 2013 Exea S.A.S
###  info@exeamedia.com www.exeamedia.com
###
###----------------------------------------###

###----------------------------------------###
### HOW-TO: run it with bash, not with sh  ###
###----------------------------------------###
###
###   bash setup.sh.txt
###

###----------------------------------------###
### DON'T EDIT ANYTHING BELOW THIS LINE    ###
###----------------------------------------###

SHELL=/bin/bash
PYTHON=/usr/bin/python

clear

echo "The Exea Media Player is installing..."

# Install the Repo for XBMC
sudo touch /etc/apt/sources.list.d/mene.list
sudo $SHELL -c "echo 'deb http://archive.mene.za.net/raspbian wheezy contrib' >> /etc/apt/sources.list.d/mene.list"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED

# Update the respository list
sudo apt-get update

# install Git
echo "Installing Git"
sudo aptitude install git
cd ~
echo "Getting the files to the Exea Media Player from Github"
git clone https://github.com/sdtorresl/ExeaMediaPlayer.git

echo "Installing XBMC"
sudo apt-get install xbmc

echo "Modifying XBMC"
cp -rp ~/ExeaMediaPlayer/xbmc/guisettings.xml ~/.xbmc/userdata/guisettings.xml
sudo cp -rp ~/ExeaMediaPlayer/xbmc/Startup.xml /usr/share/xbmc/addons/skin.confluence/720p/
sudo cp -rp ~/ExeaMediaPlayer/xbmc/DialogBusy.xml /usr/share/xbmc/addons/skin.confluence/720p/

echo "Installing LogmeIn Hamachi"
sudo apt-get install --fix-missing lsb lsb-core
sudo dpkg --force-architecture --force-depends -i ~/ExeaMediaPlayer/binaries/logmein-hamachi_2.1.0.101-1_armel.deb
sudo hamachi login
sudo hamachi attach soporte@exeamedia.com

echo "Installing Fbi"
sudo apt-get install fbi
sudo ln -s ~/ExeaMediaPlayer/pictures/splash.png /etc/splash.png
sudo ln -s ~/ExeaMediaPlayer/scripts/asplashscreen /etc/init.d/asplashscreen
sudo chmod a+x /etc/init.d/asplashscreen
sudo insserv /etc/init.d/asplashscreen

echo "Installing jsonrpclib"
$PYTHON ~/ExeaMediaPlayer/scripts/ez_setup.py
sudo easy_install jsonrpclib

echo "Installing BTSync"
mkdir ~/.btsync && cd ~/.btsync
wget http://btsync.s3-website-us-east-1.amazonaws.com/btsync_arm.tar.gz
tar -xvf btsync_arm.tar.gz 
chmod +x ./btsync
#./btsync