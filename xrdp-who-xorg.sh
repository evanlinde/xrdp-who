#!/bin/bash
#
# Print info about xrdp Xorg sessions
#

RED=$(tput setaf 1; tput bold) #"\033[1;31m"
GREEN=$(tput setaf 2; tput bold) #"\033[1;32m"
YELLOW=$(tput setaf 3; tput bold)
ENDCOLOR=$(tput sgr0) #"\033[0m"
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Format string for printf
_printf="%7s %-10s %-19s %-12s\n"

# Print header
printf "\n${_printf}" PID USERNAME START_TIME STATUS

ps h -C Xorg -o user,pid,lstart,cmd | grep xrdp | while read _ps; do
    timestring=$(echo ${_ps} | awk '{print $3,$4,$5,$6,$7}');
    start_time=$(date -d "${timestring}" +"%Y-%m-%d %H:%M:%S");
    [ $(date -d "${start_time}" +%s) -lt $(date -d "-30 days" +%s) ] && start_time="${YELLOW}${start_time}${ENDCOLOR}"
    read username pid <<< $(echo ${_ps} | awk '{print $1,$2}');
    ss -ep 2>/dev/null | grep '/xrdp_display' | grep -q pid\=${pid}, && status="${GREEN}active${ENDCOLOR}" || status="${RED}disconnected${ENDCOLOR}";
    printf "${_printf}" ${pid} ${username} "${start_time}" "${status}";
done
echo ""
