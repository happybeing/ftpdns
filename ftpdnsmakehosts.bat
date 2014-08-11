REM ftpdnsmakehosts.bat
REM
REM Download FTP DNS files and use to build a new hosts file

c:\cygwin\bin\perl /cygdrive/c/binl/ftpdnsmakehosts.pl
ipconfig /flushdns
