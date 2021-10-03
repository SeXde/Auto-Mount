#!/bin/bash

if test "$EUID" -ne 0; then
   echo "This script must be run as root"
   exit 1
fi

exitFlag=false

printf "Welcome %s to $0 \n\n" "$USER"
fdiskOutput=$(fdisk -l)
printf "%s\n\n" "$fdiskOutput"

while ! $exitFlag; do
	
	printf "\n\n"
	read -rp "Which partition would you like to mount?(Type /dev/<PartitionName>): " partition
	if echo "$fdiskOutput" | grep "$partition" &>/dev/null; then
		
		uuid=$(sudo blkid | grep /dev/sdb1 | cut -d ' ' -f 4 | sed 's/"//g')
		fsType=$(sudo blkid | grep /dev/sdb1 | cut -d ' ' -f 5 | cut -d '"' -f 2)
		printf "\n\n"
		read -rp "Introduce the mount point: " mountPoint
		mkdir -p "$mountPoint" &>/dev/null
		if mount "$partition" "$mountPoint" &>/dev/null; then

			printf "\n\n"
			printf "%s has been mounted into %s" "$partition" "$mountPoint"
			printf "\n\n"
			mount -l | grep "$partition"
			printf "\n\n"
			echo -e "$uuid\t$mountPoint\t$fsType\tdefaults\t0\t2" >>/etc/fstab
			printf "\n\n"
			printf "%s has been added to /etc/fstab" "$partition"
			printf "\n\n"
			cat /etc/fstab | tail -n 1

			while true; do
				printf "\n\n"
				read -rp "Would you like to mount another partition?[Y/N]: " res
				if test "$res" == "N" -o "$res" == "n"; then
							
					exitFlag=true
					break
				
				elif test "$res" == "Y" -o "$res" == "y"; then

					break

				fi
			
			done

		else

			printf "\n\n Something went wrong trying to mount %s into %s" "$partition" "$mountPoint"

		fi
		

	else

		printf "\n\n"
		printf "%s is not a valid partition name." "$partition"	

	fi	

done


printf "\n\nMata ne"