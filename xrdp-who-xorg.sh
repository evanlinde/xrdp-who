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
_printf="%7s %-20s %-19s %-12s\n"

# Print header
printf "\n${_printf}" PID USERNAME START_TIME STATUS

ps h -C Xorg -o user:20,pid,lstart,cmd | grep xrdp | while read username pid dt1 dt2 dt3 dt4 dt5 xorg_cmd; do
    timestring="${dt1} ${dt2} ${dt3} ${dt4} ${dt5}";
    start_time_s=$(date -d "${timestring}" +"%s");
    printf -v start_time "%(%Y-%m-%d %H:%M)T" ${start_time_s}
    [ ${start_time_s} -lt $(date -d "-30 days" +%s) ] && start_time="${YELLOW}${start_time}${ENDCOLOR}"
    ss -ep 2>/dev/null | grep '/xrdp_display' | grep -q pid\=${pid}, && status="${GREEN}active${ENDCOLOR}" || status="${RED}disconnected${ENDCOLOR}";
    printf "${_printf}" ${pid} ${username} "${start_time}" "${status}";
done
echo ""
