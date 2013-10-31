#!/bin/bash

LUSER=pi
DNAME=33
WGET=/usr/bin/wget
LOCKFILE=/home/$LUSER/sync.isrunning
LOGFILE=/home/$LUSER/exeamediaplayer/logs/playlist-sync.log

#Make sure that LOGFILE exist
if [ ! -f $LOGFILE ]; then
	mkdir /home/$LUSER/exeamediaplayer/logs
	touch $LOGFILE
	echo "Log file was created in $LOGFILE"
fi

touch ~/exeamediaplayer/playlist/sync_old
touch ~/exeamediaplayer/playlist/scheduled_old

#Make sure that sync file exist
if [ ! -f ~/exeamediaplayer/playlist/sync ]; then
	touch ~/exeamediaplayer/playlist/sync
	cp ~/exeamediaplayer/playlist/sync ~/exeamediaplayer/playlist/sync_old
	echo "Sync file was created in ~/exeamediaplayer/playlist/sync"
else
	echo "Creating a backup of sync file..."
	cp ~/exeamediaplayer/playlist/sync ~/exeamediaplayer/playlist/sync_old
fi

#Make sure that scheduled file exist
if [ ! -f ~/exeamediaplayer/playlist/scheduled ]; then
	touch ~/exeamediaplayer/playlist/scheduled
	cp ~/exeamediaplayer/playlist/scheduled ~/exeamediaplayer/playlist/scheduled_old
	echo "Scheduled file was created in ~/exeamediaplayer/playlist/sync"
else
	echo "Creating a backup of scheduled file..."
	cp ~/exeamediaplayer/playlist/scheduled ~/exeamediaplayer/playlist/scheduled_old
fi

#Check for Internet connection
ping -c 4 www.google.com > /dev/null
if [ "$?" -eq 0 ]; then
	echo "Internet connection was verified successfully...";
else
	echo "Error: There are not Internet connection, synchronization cannot be done"
	echo "Error: There are not Internet connection, synchronization cannot be done" > $LOGFILE;
	exit 1;
fi

#Get sync file
$WGET -erobots=off -O ~/exeamediaplayer/playlist/sync -o $LOGFILE http://lafayette.control.exeamedia.com/device/$DNAME/sync

#Get scheduled file
$WGET -erobots=off -O ~/exeamediaplayer/playlist/scheduled -o $LOGFILE http://lafayette.control.exeamedia.com/device/$DNAME/scheduled

#Verify that sync file is not empty
if [ -s ~/exeamediaplayer/playlist/sync ] ; then
	echo "Sync file data has been verified successfully..."
	rm ~/exeamediaplayer/playlist/sync_old
	if [ $sync_equal ]; then
		touch ~/exeamediaplayer/playlist/sync_done
	fi
else
	echo "Error: Sync file is empty. The backup file was restored";
	mv ~/exeamediaplayer/playlist/sync ~/exeamediaplayer/playlist/sync_old
	echo "Error: Sync file is empty. The backup file was restored" > $LOGFILE;
	exit 1
fi

#Verify that scheduled file is not empty
if [[ -s ~/exeamediaplayer/playlist/scheduled ]] ; then
	echo "scheduled file has data."
	rm ~/exeamediaplayer/playlist/scheduled_old
	if [ $scheduled_equal ]; then
		touch ~/exeamediaplayer/playlist/scheduled_done
	fi
else
	echo "Error: Scheduled file is empty. The backup file was restored";
	mv ~/exeamediaplayer/playlist/scheduled ~/exeamediaplayer/playlist/scheduled_old
	echo "Error: Scheduled file is empty. The backup file was restored" > $LOGFILE;
	exit 1
fi
