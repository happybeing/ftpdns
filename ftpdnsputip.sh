#!/bin/bash
#
# ftpdnsputip.sh - uploads a <hostname>.getmyip file to an ftp server for simple dynamic DNS
#
# <hostname>.getmyip is a single line file with a /etc/hosts style domain entry
#
# SFTP v FTP
# I've stuck with FTP because overall it has lower security risks in this application than
# would SFTP. That's because I would be forced to include the cPanel master account login
# credentials in each script and that makes the main hosting account vulnerable. Whereas
# FTP, while more likely to be compromised, exposes information that would be hard to
# make use of (requiring further very sophisitacted attacks), and even then, only yield
# access to a network that has only three machines with no sensitive information on
# them. So an attacker would have to go to a lot of effort, and then only have the
# ability to perform a DoS attack, that would also be easy to recover from (as it happens).
#	- mrh 04.Aug.14
#
# History (pre git)
#  			06-08-2014	Initial version.
#  			07-08-2014	Changed command interpreter path (first line was #!/usr/bin/bash)
#  			12-08-2014	Tweaks to accommodate README.TXT documentation.
#
# License
#
#    Copyright 2014 Mark Hughes, http://markhughes.com.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#######################################################################################
TMPPATH=<pathtotemp>
IPFILE=$TMPPATH/getmyip.tmp					#This comment fixes script error on Windows
HOSTNAME=${COMPUTERNAME:-`hostname`}	# Get lc hostname on Windows/Linux
HOSTSFILE=${HOSTNAME,,}.getmyip			#This comment fixes script error on Windows
wget -qO $IPFILE http://<webhostdomain>/getmyip.php >/dev/null
echo `cat $IPFILE` " $HOSTNAME" > $TMPPATH/$HOSTSFILE		#This comment fixes script error on Windows
#
# ftp upload the file
HOST=<ftphost>		#This is the FTP servers host or IP address.
USER=<ftpuser>		#This is the FTP user that has access to the server.
PASS=<ftppassword>	#This comment fixes script error on Windows
#
cd $TMPPATH 		#This comment fixes script error on Windows
ftp -in $HOST << EOF
user $USER $PASS
put $HOSTSFILE
bye
EOF
