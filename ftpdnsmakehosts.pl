#!/usr/bin/perl
#
# ftpdnsmakehosts.pl - download ftpdns files and create a new hosts file
#
# Written in perl for portability, tested on:
#       - Windows 7 (with cygwin + cygwin perl).
#       - Linux Mint Debian Edition (Betsy)
#
# Windows
# Script variables have paths set for Windows, but check they are correct for your system.
# You will also need to ensure the ftp server, username and password are correctly set
#
# This script is intended to be called by a Windows batch file containing something like:
#       c:\cygwin\bin\perl /cygdrive/c/binl/ftpdnsmakehosts.pl
#       ipconfig /flushdns
#
# Linux
# Script variables have paths set for Windows, so you need to modify these for Linux
# You will also need to ensure the ftp server, username and password are correctly set
#
# Then, to update your /etc/hosts file use:
#       sudo ./ftpdnsmakehosts.pl
#
# NOTES:
# See also ftpdnsputip.sh which obtains the machine IP address from a web server script,
# saves it as a hosts entry ("IP host") in a "hostname.getmyip" file and uploads that
# file to an FTP server. Multiple hosts can upload files to the same directory, and then
# this script can automate the process of downloading those files and editing an
# existing hosts file to include the IP addresses of each machine that uploaded a file.
# The script ignores any file placed on the FTP server by this host, so only other
# hosts are listed in the hosts file.
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
# Configuration
my $FTPHOST="<ftphost>";
my $FTPUSER="<ftpuser>";
my $FTPPASS='<ftppassword>';
#
# Windows settings
my $HOSTSFILE="C:\\windows\\system32\\drivers\\etc\\hosts";
#
## Download the FTP DNS files
#
# Grab all <hostname>.getmyip files from FTP server
#
use Net::FTP;

$ftp = Net::FTP->new($FTPHOST, Debug => 0)
or die "Cannot connect to host: $@";

$ftp->login($FTPUSER,$FTPPASS)
or die "Cannot login ", $ftp->message;

$ftp->cwd("/")
or die "Cannot change working directory ", $ftp->message;

@list = $ftp->dir()
or die "dir failed ", $ftp->message;

# Download each <hostname>.getmyip file
foreach my $entry ( @list ) {
	(my $filename = $entry ) =~ s/.* ([a-zA-Z]+\.getmyip).*/\1/;
	( $filename ne $entry ) && 
		( $ftp->get($filename)
		  or die "get failed ", $ftp->message );
}

$ftp->quit;

# Get the local part of hosts into a temp file
my $HOSTSTEMP=$HOSTSFILE . ".tmp";

open(INFILE,"<", $HOSTSFILE) or die "Unable to open hosts: $HOSTSFILE";
open(OUTFILE,">",$HOSTSTEMP) or die "Unable to write temp hosts: $HOSTSTEMP";

# Markers used to delimit auto generated section of hosts file
my $FTPDNSSTARTTEXT="##### START DNS HOSTS - DO NOT EDIT";
my $FTPDNSENDTEXT=  "##### END   DNS HOSTS - DO NOT EDIT";

# Copy existings hosts file except for any existing FTPDNS section

my $includeFlag = 1;
while(<INFILE>){
		if ( /$FTPDNSSTARTTEXT/ ){	$includeFlag = 0;}
		if ($includeFlag){ print OUTFILE $_;}
		if ( /$FTPDNSENDTEXT/ ){ $includeFlag = 1; }
}

# Now grab the ".getmyip" files

opendir my($dh), "." or die "Couldn't open dir '$dirname': $!";
my @list = readdir $dh;
closedir $dh;

# Append FTPDNS section, excluding self from the list

$thishostname=lc($ENV{'COMPUTERNAME'});

print OUTFILE "$FTPDNSSTARTTEXT\r\n";
foreach my $entry ( @list ) {
	if ( $entry =~ m/^[a-zA-Z]+\.getmyip$/ ){
		my $nexthostname = $entry;
		$nexthostname =~ s/(.*)\.getmyip/\1/;
		if ( $thishostname ne $nexthostname){
			open(INFILE, "<", $entry) or die "Failed to open downloaded file: $entry";
			while(<INFILE>){print OUTFILE "$_\r\n";}
			close(INFILE);
		}
		unlink($entry) or die "Failed to delete downloaded file: $entry";
	}
}
print OUTFILE "$FTPDNSENDTEXT\r\n";
close(OUTFILE);

# Replace hosts file and tidy up
use File::Copy 'move';
move $HOSTSTEMP, $HOSTSFILE or WriteLog ("Failed to move $HOSTSTEMP, $HOSTSFILE: $!");
