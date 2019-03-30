#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run autorandr -c
run nm-applet
run volumeicon
run gnome-screensaver
run solaar
run xbindkeys
run compton
run setxkbmap -layout us_intl -option ctrl:swapcaps
