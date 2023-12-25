#!/bin/bash
selected_songs=$(yad --file-selection --multiple --file-filter='*.mp3')
file_paths=$( echo "$selected_songs" | tr "|" "\n")
declare -a file_array
all_file_mp3=true
while read -r file_path; do
    file_array+=("$file_path")
done <<< "$file_paths"

  for song in "${file_array[@]}"; do
        if [[ ! "$song" =~ \.mp3$ ]]; then
            all_file_mp3=false
            break
        fi
    done
    
if [ -n "$file_paths" ] && [ "$all_file_mp3" = true ]; then
truncate -s 0 ./PBL4/LinkAudio.m3u
for file_path in $file_paths; do
     echo "$file_path" >> ./PBL4/LinkAudio.m3u
 done
        mpg123_pid=0
        sed -i "1s/.*/$mpg123_pid/" ./PBL4/important.txt
        position_song=1
        sed -i "2s/.*/$position_song/" ./PBL4/important.txt
        chosen=true
        sed -i "3s/.*/$chosen/" ./PBL4/important.txt
else
     chosen=false
     sed -i "3s/.*/$chosen/" ./PBL4/important.txt
fi
exit 0
