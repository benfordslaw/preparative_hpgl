#!/bin/bash

MODEL=$1 # whatever GGUF you want to use
LLAMA=(./llama-cli -m "$MODEL" 
    -no-cnv --no-display-prompt
    --temp 1000)

echo -n "IN;IP;SP1;SS;SR0.3,0.8;DT.;PU1000,1000;"

"${LLAMA[@]}" --grammar 'root ::= ("- " [a-z ]+ "\n")+' -p "a list of scary things:\n" 2>/dev/null | \
while IFS= read -r scary; do
    # group location
    x=$(( 100 + (98 * (RANDOM % 100)) ))
    y=$(( 100 + (58 * (RANDOM % 100)) ))
    echo -n "PU${x},${y};"

    prompt="a short list of objects to protect me from $(echo $scary | cut -d '-' -f 2):\n"

    min_x=9800
    max_y=0
    min_y=5800

    shopt -s lastpipe # allows modifying max/min
    "${LLAMA[@]}" --grammar 'root ::= ("- " [a-z ]+ "\n"){2,5}' -p "$prompt" 2>/dev/null | \
    while IFS= read -r protect; do
        [[ -z $protect ]] && continue
        [[ $protect == *'[end of text]'* ]] && continue

        [[ $x -lt $min_x ]] && min_x=$x
        [[ $y -lt $min_y ]] && min_y=$y
        [[ $y -gt $max_y ]] && max_y=$y

        protect=$(echo $protect | cut -d '-' -f 2)
        echo -n "PU${x},${y};CP2.5,1;LT;LB$(echo $protect | cut -d '-' -f 2).;PU${x},${y};CP2,0.5;WG25,0,360;PU${x},${y};CP2,0.5;CI25;"

        x=$(( x + ( RANDOM % 2000 ) - 1000 ))
        y=$(( y + ( RANDOM % 2000 ) - 1000 ))
    done
    echo -n "PU${min_x},${max_y};CP1,2;FT1;RA${min_x},${min_y};"
done
