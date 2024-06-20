#!/bin/bash
#
# Print usernames and login times of the running xrdp sessions
# in a format like the "who" command.
#

# Get xrdp version info -- needed to correctly determine session backend
read vmajor vminor vpatch <<< $(xrdp --version | awk 'NR==1{gsub(/\./," ",$2);print $2}')

# First find the xrdp-sesman service that was started by init or systemd
sesman_pid=$(ps --no-header -o ppid,pid -C xrdp-sesman | awk '$1==1 {print $2}')

if [[ -z ${sesman_pid} ]]; then
    echo "Cannot report xrdp sessions -- xrdp-sesman process not found!" 1>&2
    exit
fi

# Then find the child processes. This process should also be "xrdp-sesman"
# but on some older versions, it may be "xrdp-sessvc". There should be one 
# of these processes for each logged in user
sesman_children=($(ps --no-header -o pid --ppid ${sesman_pid}))

# Starting with xrdp 0.10.0, the first child of each sesman child process
# should be the session backend executable and the second child should be
# the user's window manager; before 0.10.0, these two are switched. The 
# third child of each sesman child process should be xrdp-chansrv. All of
# these processes should be running as the logged in user, but on some 
# older versions, the chansrv process may not be.
if [[ ${vmajor} -eq 0 ]] && [[ ${vminor} -lt 10 ]]; then
    child_order=2
else  # 0.10.0 and later
    child_order=1
fi
for ppid in ${sesman_children[@]}; do 
    read username session lstart <<< $(ps --no-header -o user:20,comm,lstart --ppid ${ppid} | sed -n "${child_order}p")
    start_time=$(date --date="${lstart}" +"%Y-%m-%d %H:%M")
    printf "%-23s%s (%s)\n" "${username}" "${start_time}" "${session}"
done
