#!/bin/bash
#########################################################
#                                                       #
#              DMRCZ Updater                            #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                  Enhanced by DMRCZ                    #
#                    Version 0.1 alfa                   #
#                                                       #
#                                                       #
#########################################################


# Files and locations
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
RADIOIDDB=/tmp/user.csv
GROUPSTXT=/usr/local/etc/groups.txt
STRIPPED=/usr/local/etc/stripped.csv
COUNTRIES=/usr/local/etc/country.csv

# How many backups?
FILEBACKUP=1

# Command line to restart MMDVMHost
RESTARTCOMMAND="systemctl restart mmdvmhost.service"

# Check we are root
if [ "$(id -u)" != "0" ];then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
	cp  ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
	cp  ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
	cp  ${RADIOIDDB} ${RADIOIDDB}.$(date +%Y%m%d)
	cp  ${GROUPSTXT} ${GROUPSTXT}.$(date +%Y%m%d)
	cp  ${STRIPPED} ${STRIPPED}.$(date +%Y%m%d)
	cp  ${COUNTRIES} ${COUNTRIES}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${RADIOIDDB}
${GROUPSTXT}
${STRIPPED}
${COUNTRIES}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
	for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
	do
		rm $f
	done
  fi
done

# Generate Host Files

curl 'https://barrandovhblink.jednoduse.cz/dmrcz/DMRIds.dat' 2>/dev/null > ${DMRIDFILE}
curl 'https://barrandovhblink.jednoduse.cz/dmrcz/DMR_Hosts.txt' 2>/dev/null > ${DMRHOSTS}
curl 'https://barrandovhblink.jednoduse.cz/dmrcz/user.csv' 2>/dev/null > ${RADIOIDDB}
curl 'https://barrandovhblink.jednoduse.cz/dmrcz/groups.txt' 2>/dev/null > ${GROUPSTXT}
curl 'https://barrandovhblink.jednoduse.cz/dmrcz/stripped.csv' 2>/dev/null > ${STRIPPED}
curl 'https://barrandovhblink.jednoduse.cz/dmrcz/country.csv' 2>/dev/null > ${COUNTRIES}


# Restart MMDVMHost
eval ${RESTARTCOMMAND}
