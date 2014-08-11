ftpdns
======

Create your own Dynamic DNS using files shared using an ftp account and a web hosting service

LICENSE
    Copyright 2014 Mark Hughes, http://markhughes.com.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

DESCRIPTION
ftpdns is a hack... you need web hosting to: 
	- host a trivial PHP script 
	- provide an ftp server account

It is pure co-incidence that I operate a suitable UK based hosting service,
at http://managedwebsitehosting.net

Each machine to be accessed remotely using the DNS runs a bash script that 
gets its public IP and uploads this and its hostname in a file to the ftp 
account. My machines Linux/Win7 run this script regularly using cron/scheduler.

I've written a short client script in perl that grabs the files from the ftp 
server and edits the local hosts file to insert entries for reach machine, 
while preserving the rest of the file.

On windows I have cygwin Perl installed.

Important thing is its simple, free and works. :-)

INSTALLATION & TESTING
You will need a web hosting service (such as my UK based 
http://managedwebsitehosting.net <- repeat shameless plug) where you 
can a) host a trivial PHP script, and b) create a password protected 
ftp account where these scripts can upload and access some small 
text files (one tiny file per remote machine).

Set up a password protected ftp account that will be used to store 
and access files containing DNS details. 

Edit the following files and replace elements inside '<' and '>' 
(e.g. <webhostdomain>) to refer to the web hosting and FTP 
services and account you are going to use.

	ftpdnsputip.sh
	ftpdnsmakehosts.pl	
	
On Windows machines you might want the very simple wrappers for these
files ftpdnsputip.bat and ftpdnsmakehosts.bat. All files need to be
somewhere on the path, or if not, you can specify the full path 
whenever you run them (e.g. from command line, cron or Task Scheduler).

Ensure the ftp and scripts they refer to are in place as follows.

I suggest you upload a copy of the edited ftpdns files in a folder of 
this ftp account to make it easy to install the files on any machines 
featuring in or using ftpdns.

Upload getmyip.php to your web hosting service, accessible 
as http://<webhostdomain>/getmyip.php or similar.

On each remote machine you want to be accessible using this Dynamic DNS:
	- ftpdnsputip.sh (on Windows you might also want the wrapper ftpdnsputip.bat)
	- a suitable 'bash' shell (e.g. cygwin on Windows)
	- wget (e.g. cygwin on Windows)
	- a cron or Windows Task Scheduler job to run ftpdnsputip.sh automatically (e.g. every 15 minutes)
	- a standard ftp command line program (e.g. cygwin on Windows, or on Linux run: sudo apt-get install ftp)
	- commands and scripts need to be somewhere on the path, or if not, you can specify the full path 
	  whenever you run them (e.g. from command line, cron or Task Scheduler).
	Note: these tested on Windows 7 and Ubuntu 14.04 LTS

	
On each machine you want to be able to access the remote machines you need:
	- ftpdnsmakehosts.pl (on Windows you might also want the wrapper ftpdnsmakehosts.bat)
	- a suitable Perl interpreter (e.g. cygwin on Windows)
	- a standard ftp command line program (e.g. cygwin on Windows, 
	  or on Linux run: sudo apt-get install ftp)
	- commands and scripts need to be somewhere on the path, or if not, you can specify the full path 
	  whenever you run them (e.g. from command line, cron or Task Scheduler).
	Note: these tested only on Windows 7


Sorry for requiring Perl and bash, but I decided to use Perl 'after' 
I wrote the bash script. Feel free to convert ftpdnsputip.sh to Perl!

Its fine for a machine to act in both roles at once.

TESTING Using The Command Line

Testing - on each machine to be accessed via Dynamic DNS:
1) Inserting your web hostname, check that you can manually obtain 
a "somename.getmyip" file with:
	wget -qO somename.getmyip http://<webhostdomain>/getmyip.php >/dev/null

2) Check the content of the somename.getmyip file looks like a 
valid "hosts" file entry, for example:

	12.45.56.78	somename

You can access the http://<webhostdomain>/getmyip.php in a web browser 
to verify this.

3) Use command line ftp to verify the machine can login to ftp, and 
then UPLOAD the "somename.getmyip" file from step 1)

Testing - on each machine that will access other machines via Dynamic DNS:
4) Use command line ftp to verify the machine can login to ftp, and 
then DOWNLOAD a previously uploaded "somename.getmyip" file.

5) Check you can repeat the effect of 1), 2) and 3) using ftpdnsputip.sh

6) From the directory containing your hosts file (/etc on Linux, 
C:\Windows\system32\drivers\etc\ on Windows 7), make a backup copy of your
hosts file. Then manually run ftpdnsmakehosts.pl, for example using:
	On Windows you will need Administrator permissions
		c:\cygwin\bin\perl /cygdrive/c/binl/ftpdnsmakehosts.pl

	On Linux you will need to use "sudo" when running manually, or run the
	script using the root crontab, because it needs to edit the "hosts" file.
	
The above is to verify that it downloads all *.getmyip files stored on the 
ftp server and inserts an entry for each in the hosts file (while preserving 
everything else). Repeating the command will just update the inserted 
section which will look something like this:

##### START DNS HOSTS - DO NOT EDIT
98.19.245.34  tantalum
23.87.237.52  bargee

##### END   DNS HOSTS - DO NOT EDIT

7) Try "ping tantalum" etc to verify you machine picks this up. On Windows I
provide a wrapper (ftpdnsmakehosts.bat) that runs the command followed by
"ipconfig /flushdns" although this does not seem to be necessary.

8) Once you have set up cron (Linux) or Task Scheduler (Windows) jobs to 
run the ftpdnsputip.sh script regularly, verify that it does indeed update 
the files on the ftp server whenever those machines are on.
