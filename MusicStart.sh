#!/bin/bash
pipe=./PBL4/test
trap "rm -f $pipe" EXIT
if [[ ! -p $pipe ]]; then
   mkfifo $pipe
   fi
mpg123 -R --fifo ./PBL4/test 
exit 0
     


