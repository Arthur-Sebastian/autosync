#!/bin/bash

#find absolute script path for mount
scriptfile=`realpath $0`
scriptpath=`dirname $scriptfile`
progname="\e[1;36m[AutoSync]\e[0m"
ofs="          "

scrubDirectory ()
{
	while IFS=": " read -r a b where what; do
		case $syncdir in
			d )	echo -e "$ofs File: '$what' only found in local.";
				rm -r $where/$what;;
			u )	echo -e "$ofs File: '$what' only found in remote.";
				rm -r $where/$what;;
		esac
	done < <(diff -qr $scriptpath/remote$remote $local -x ".*")
	echo -e "$ofs Directory scrub complete."
}

echo -e "$progname Reading configuration..."
#read and parse config file
while IFS== read -r i o; do
	declare "$i"="$o"
done < $scriptpath/config
#display config
echo -e "$ofs Synchronising with: //$ip/$path"
echo -e "$ofs Synchronisation list: $synclist"
echo -e "$ofs Credentials file: $credentials"
echo -e "$ofs Local user/local group: $localuser/$localgroup"
#attempt mounting
echo -e "$progname Attempting to mount remote..."
sudo mount -t cifs //$ip$path $scriptpath/remote -o credentials=$scriptpath/credentials/$credentials,gid=artur,uid=artur
#check mount result
if [ $? -ge 1 ]; then
	#try unmounting
	sudo umount $scriptpath/remote
	#unmount fails, exit
	if [ $? -ge 1 ]; then
		echo -e "$progname Mount cannot proceed. Exiting.";
		sleep 1
		exit
	fi
	#if unmount is successful, try again
	echo -e "$ofs Mount failed. Retrying."
	sudo mount -t cifs //$ip$path $scriptpath/remote -o credentials=$scriptpath/credentials/$credentials,gid=$localgroup,uid=$localuser
	#if remount fails, exit
	if [ $? -ge 1 ]; then
		echo -e "$progname Retry failed. Exiting.";
		sleep 1
		exit
	fi
fi
#ask for sync direction
while true; do
	echo -e "$progname Sync up, down or cancel?"
	read -p "$ofs [u/d/c]" syncdir
	case $syncdir in
		[ud]* ) break;;
		c ) echo -e "$progname Sync cancelled. Exiting!";
			sudo umount $scriptpath/remote;
			sleep 2;
			exit;;
		* ) echo "$ofs Answer u/d/c.";; 
	esac
done
#start syncing according to specified direction
while IFS="," read -r remote local; do
	case $syncdir in
		d )	echo -e "$progname Downloading: $remote";
			rsync -rlptu --exclude=.git $scriptpath/remote$remote `dirname $local`;
			echo -e "$progname Scrubbing: $remote";
			scrubDirectory;;
			
			
		u )	echo -e "$progname Uploading: $local"	
			rsync -rlptu --exclude=.git $local `dirname $scriptpath/remote$remote`;
			echo -e "$progname Scrubbing: $local";
			scrubDirectory;;
	esac
done < $scriptpath/$synclist
#unmount after those are complete
echo -e "$progname Tasks completed. Unmounting..."
sleep 2;
sudo umount $scriptpath/remote
