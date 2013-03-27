#!/usr/bin/expect

set file [lindex $argv 0]
set server_path [lindex $argv 1]

set ftp_user [lindex $argv 2]
set pass [lindex $argv 3]

eval spawn scp -P 9022 $file $ftp_user@ftp.forio.com:/$server_path
#use correct prompt
set prompt ":|#|\\\$"
interact -o -nobuffer -re $prompt return
send "$pass\r"
interact