#!/bin/bash
 pipe=./PBL4/test
 echo 'stop'>$pipe
 IFS=$'\n' read -r -d '' -a file_paths < ./PBL4/LinkAudio.m3u
 num_files=${#file_paths[@]}
 position_song=$(sed -n '2p' ./PBL4/important.txt)
 if [ $position_song -eq  $num_files ];then
    position_song=1;
 else 
    position_song=$((position_song+1));
    fi
    sed -i "2s/.*/$position_song/" ./PBL4/important.txt
    mpg123_pid=0
    sed -i "1s/.*/$mpg123_pid/" ./PBL4/important.txt
