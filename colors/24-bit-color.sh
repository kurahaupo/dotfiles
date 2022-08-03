#!/bin/bash
# This file was originally taken from iterm2 https://github.com/gnachman/iTerm2/blob/master/tests/24-bit-color.sh
#
#   This file echoes a bunch of 24-bit color codes
#   to the terminal to demonstrate its functionality.
#   The foreground escape sequence is ^[38;2;<r>;<g>;<b>m
#   The background escape sequence is ^[48;2;<r>;<g>;<b>m
#   <r> <g> <b> range from 0 to 255 inclusive.
#   The escape sequence ^[0m returns output to default

setBackgroundColor()
{
    printf '\e[48;2;%u;%u;%um%s' "$1" "$2" "$3" "${*:4}"
}

resetOutput()
{
    printf '\e[0m\n'
}

# Gives a color $1/258 % along HSV
# Wraps around when $1 > 257; fails if $1 < 0
# Echoes "$red $green $blue" where
# $red $green and $blue are integers
# ranging between 0 and 255 inclusive
setRainbowBackgroundColor()
{
    local -i c=$1 m h t
    (( m=43*6 ))
    (( c %= m, c<0 && (c+=m) )) # fix up numbers outside range
    (( h=c/43%6 ))              # selector (0-5)
    (( t=c%43*255/43 ))         #

    local -ai rgb=( 0 0 0 )
    case $h in
     0) rgb=( 255   t     0     ) ;;
     1) rgb=( 255-t 255   0     ) ;;
     2) rgb=( 0     255   t     ) ;;
     3) rgb=( 0     255-t 255   ) ;;
     4) rgb=( t     0     255   ) ;;
     5) rgb=( 255   0     255-t ) ;;
    fi

    setBackgroundColor "${rgb[@]}" "${*:2}"
}

for i in {0..127};   do setBackgroundColor "$i" 0 0 ' ' ; done ; resetOutput
for i in {255..128}; do setBackgroundColor "$i" 0 0 ' ' ; done ; resetOutput

for i in {0..127};   do setBackgroundColor 0 "$i" 0 ' ' ; done ; resetOutput
for i in {255..128}; do setBackgroundColor 0 "$i" 0 ' ' ; done ; resetOutput

for i in {0..127};   do setBackgroundColor 0 0 "$i" ' ' ; done ; resetOutput
for i in {255..128}; do setBackgroundColor 0 0 "$i" ' ' ; done ; resetOutput

for i in {0..128};   do setRainbowBackgroundColor "$i" ' ' ; done ; resetOutput
for i in {257..129}; do setRainbowBackgroundColor "$i" ' ' ; done ; resetOutput
