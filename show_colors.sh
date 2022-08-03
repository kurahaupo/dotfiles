#!/bin/bash
#
#   This file echoes a bunch of color codes to the
#   terminal to demonstrate what's available.  Each
#   line is the color code of one forground color,
#   out of 17 (default + 16 escapes), followed by a
#   test use of that color on all nine background
#   colors (default + 8 escapes).
#

T=gYw   # The test text
# ASCII escape char is 27, Hex \x1B, Octal 033

ColorNames=( Black Red Green Yellow Blue Magenta Cyan White - Default )
LightOrDark=( '' 'Bright ' )

printf '\n                '
printf ' %-7.7s' "${ColorNames[9]}" "${ColorNames[@]:0:8}"
printf '\n            '
printf ' %7u' 49 {40..47}
printf '\n'

for fg in 39 {30..37} ; do
  for ld in 0 1 ; do
    printf '%-15s ' "${LightOrDark[ld]}${ColorNames[fg-30]}"
    for bg in 49 {40..47}; do
      printf '\e[%u;%u;%um  %-5s\e[m ' "$fg" "$bg" "$((ld?1:22))" "$T"
    done
    printf '\e[m\n'
  done
done
echo
