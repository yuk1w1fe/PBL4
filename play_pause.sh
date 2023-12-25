#!/bin/bash
mpg123_pid=$(sed -n '1p' ./PBL4/important.txt)
position_song=$(sed -n '2p' ./PBL4/important.txt)
file_path=$(<./PBL4/LinkAudio.m3u)
 IFS=$'\n' read -r -d '' -a file_paths < ./PBL4/LinkAudio.m3u
 num_files=${#file_paths[@]}
 pipe=./PBL4/test
        if [ $num_files -gt 0 ]; then
         if [ $mpg123_pid -eq 0 ]; then
         echo "loadlist $position_song ./PBL4/LinkAudio.m3u">$pipe
          mpg123_pid=$!
          sed -i "1s/.*/$mpg123_pid/" ./PBL4/important.txt
         else 
         echo 'pause'>$pipe
          fi
        else 
          zenity --info --title="Notification" --text="<span font='Arial 12' weight='bold' foreground='#0077CC'>THE FILE AUDIO DOES NOT EXIST!!!</span>" 
         fi
exit 0





