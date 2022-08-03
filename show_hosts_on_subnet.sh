#!/bin/bash

need() {
  for c do
    command -v "$c" >/dev/null && continue
    echo >&2 "please install $c"
    exit 1
  done
}
need ipcalc

default_dev=$( netstat -rnf inet |
               grep default |
               awk '{print $6}' )

broadcast=$( ifconfig $default_dev |
             grep broadcast |
             awk '{ print $2 " " $4}' |
             xargs ipcalc --nobinary |
             awk '/Network/ { print $2 }' )
             
sudo nmap -sn "$broadcast" |
  awk '/scan report/ { ip = $5; getline; getline; print ip " " $0  }'
