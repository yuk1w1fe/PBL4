#!/bin/bash
 pipe=./PBL4/test
mpg123_pid=$(sed -n '1p' ./PBL4/important.txt)
clicked(){
        if [ -z "$mpg123_pid" ]; then
           echo "jump +10s">$pipe
         fi
}
    clicked
exit 0
