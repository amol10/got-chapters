#!/bin/bash

chapters_per_line=5

books_dir="/home/amol/Books/books/game_of_thrones"
declare -A books=( ["agot"]="${books_dir}/A Game Of Thrones - George RR Martin.pdf"
    ["acok"]="${books_dir}/A Clash of Kings - George RR Martin.pdf"
    ["asos"]="${books_dir}/A Storm of Swords - George RR Martin.pdf"
    ["affc"]="${books_dir}/A Feast For Crows - George RR Martin.pdf"
    ["adwd"]="${books_dir}/A Dance With Dragons - George RR Martin.pdf"
)
book=$1
path=${books[$book]}
echo $path

skip=("TITLE PAGE" "COPYRIGHT" "CONTENTS" "DEDICATION" "MAPS" "PROLOGUE")
title=
page=
c=$chapters_per_line
skipl=0
tmpfile=$(mktemp)
echo > $tmpfile
pdftk "$path" dump_data | grep -B1 -A1 "BookmarkLevel: 1" | grep -P "Title|PageNumber" | while read -r line
do
    #echo $line
    if [ $skipl -eq 1 ]
    then
        skipl=0
        #echo skipl
        continue
    fi
    if [[ -z "$title" ]]
    then
        title=$(echo $line | sed -e 's/\w\+:\s\+//')
        if [ "$title" == "APPENDIX" ]
        then
            break
        fi

        if [[ "${skip[*]}" =~ "$title" ]]
        then
            #echo skipping...
            skipl=1
            title=
        else
            title=$(echo $title | sed -e 's/\(\w\)\(\w\+\)/\u\1\L\2/')
            echo -n -e $title \\t >> $tmpfile
        fi
        continue
    fi
    
    if [[ -z "$page" ]]
    then
        page=$(echo $line | grep -Po "\d+")
        echo -n -e $page \\t >> $tmpfile

        title=
        page=
        c=$(( c - 1 ))
        if [ $c -eq 0 ]
        then
            c=$chapters_per_line
            echo >> $tmpfile
        fi
    fi
done
echo >> $tmpfile

cat $tmpfile | column -t