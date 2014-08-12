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

# Show errors
function catch_errors() {
   echo "Error";
}

function usage() {
	echo -e "Usage: $0 [arguments]\n"

	echo -e "-H, --home [HOME]\tSpecify the install directory"
	echo -e "-f, --force\t\tForce logmeIn Hamachi installation"
	echo -e "-h, --help\t\tPrint this help\n"

	echo "Examples:"
	echo -e "\t$0 --home /home/user"
	echo -e "\t$0 -f"
	echo -e "\t$0 --help"
}

trap catch_errors ERR;

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

SHELL=/bin/bash
PYTHON=/usr/bin/python
HOME=/home/pi
FORCE=0

while [ "$1" != "" ]; do
    case $1 in
        -H | --home )
			shift
            HOME=$1
			;;
        -f | --force )
			FORCE=1
            ;;
        -h | --help )
			usage
            exit
            ;;
        * ) 
			usage
            exit 1
    esac
    shift
done


clear

echo "The Exea Media Player is installing..."

# Install the Repo for XBMC
touch /etc/apt/sources.list.d/mene.list
$SHELL -c "echo 'deb http://archive.mene.za.net/raspbian wheezy contrib' >> /etc/apt/sources.list.d/mene.list"
apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED

# Update the respository list
apt-get -y update

# install Git
echo "Installing Git..."
apt-get -y install git
cd $HOME
echo "Removing previous installation of ExeaMediaPlayer..."
rm -rf $HOME/ExeaMediaPlayer
echo "Getting the files to the Exea Media Player from Github..."
git clone https://github.com/sdtorresl/ExeaMediaPlayer.git

echo "Installing XBMC..."
sudo apt-get install xbmc

echo "Modifying XBMC..."
cp -rp $HOME/ExeaMediaPlayer/xbmc/guisettings.xml $HOME/.xbmc/userdata/guisettings.xml
cp -rp $HOME/ExeaMediaPlayer/xbmc/Startup.xml /usr/share/xbmc/addons/skin.confluence/720p/
cp -rp $HOME/ExeaMediaPlayer/xbmc/DialogBusy.xml /usr/share/xbmc/addons/skin.confluence/720p/
cp -rp $HOME/ExeaMediaPlayer/xbmc/VideoFullScreen.xml /usr/share/xbmc/addons/skin.confluence/720p/
cp -rp $HOME/ExeaMediaPlayer/xbmc/advancedsettings.xml /usr/share/xbmc/system
cp -rp $HOME/ExeaMediaPlayer/xbmc/RssFeeds.xml $HOME/.xbmc/userdata
cp -rp $HOME/ExeaMediaPlayer/xbmc/xbmc /etd/default/xbmc
cp -rp $HOME/ExeaMediaPlayer/xbmc/.bashrc $HOME/ExeaMediaPlayer/xbmc/.bashrc

echo "Installing Fbi..."
apt-get install fbi
ln -s $HOME/ExeaMediaPlayer/pictures/splash.png /etc/splash.png
ln -s $HOME/ExeaMediaPlayer/scripts/asplashscreen /etc/init.d/asplashscreen
chmod a+x /etc/init.d/asplashscreen
insserv /etc/init.d/asplashscreen

echo "Installing jsonrpclib..."
$PYTHON $HOME/ExeaMediaPlayer/scripts/ez_setup.py
easy_install jsonrpclib

echo "Installing BTSync..."
mkdir $HOME/.btsync
cd $HOME/.btsync
wget http://btsync.s3-website-us-east-1.amazonaws.com/btsync_arm.tar.gz
tar -xvf btsync_arm.tar.gz
chmod +x ./btsync
./btsync & >> /dev/null

cd $HOME/ExeaMediaPlayer
mkdir $HOME/ExeaMediaPlayer/media/share/

installLogmeIn="n"
if [[ FORCE -eq 0 ]]; then
	echo "Install LogmeIn Hamachi? (Y/n)"
	read installLogmeIn
else
	installLogmeIn="Y"
fi

if [[ installLogmeIn -eq "Y" ]]; then
	#statements
	apt-get install --fix-missing lsb lsb-core
	dpkg --force-architecture --force-depends -i $HOME/ExeaMediaPlayer/binaries/logmein-hamachi_2.1.0.101-1_armel.deb
	hamachi login
	echo "Write the e-mail to attach account:"
	read email
	hamachi attach $email
	echo "Write the nickname for use: "
	read nickname
	hamachi set-nick $nickname
else
	echo "LogmeIn Hamachi will be not installed"
fi

chown -R pi:pi $HOME
cd $HOME

exit 0
