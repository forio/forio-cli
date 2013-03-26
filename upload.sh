#!/usr/bin/expect

set file [lindex $argv 0]
set sim [lindex $argv 1]
set author [lindex $argv 2]
set server_path [lindex $argv 3]
set pass [lindex $argv 4]

eval spawn scp -P 9022 $file $author@ftp.forio.com:/$author/$sim/$server_path
#use correct prompt
set prompt ":|#|\\\$"
interact -o -nobuffer -re $prompt return
send "$pass\r"
interact