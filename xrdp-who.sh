#!/bin/bash
#
# Print usernames and login times of the running xrdp sessions
# in a format like the "who" command.
#

# First find the xrdp-sesman service that was started by init or systemd
sesman_pid=$(ps --no-header -o ppid,pid -C xrdp-sesman | awk '$1==1 {print $2}')

# Then find the child processes. This process should also be "xrdp-sesman"
# but on some older versions, it may be "xrdp-sessvc". There should be one 
# of these processes for each logged in user
sesman_children=$(ps --no-header -o pid --ppid ${sesman_pid})

# The first child of each sesman child process should be the user's window
# manager; the second should be the session backend executable; the third
# should be xrdp-chansrv. The first two should be running as the logged in
# user, but on some older versions, the chansrv process may not be.
for ppid in ${sesman_children}; do 
    read username session lstart <<< $(ps --no-header -o user,comm,lstart --ppid ${ppid} | sed -n '2p')
    start_time=$(date --date="${lstart}" +"%Y-%m-%d %H:%M")
    printf "%-23s%s (%s)\n" "${username}" "${start_time}" "${session}"
done
