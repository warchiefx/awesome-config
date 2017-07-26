#!/usr/bin/bash
start-pulseaudio-x11
eval `ssh-agent -s`
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
exec awesome
