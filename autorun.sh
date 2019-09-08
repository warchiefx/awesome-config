#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run /usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run autorandr -c
run nm-applet
run volumeicon
run gnome-screensaver
run solaar
run xbindkeys
run compton
run setxkbmap -layout us -variant altgr-intl -option ctrl:swapcaps
