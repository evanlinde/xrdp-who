#!/bin/bash
#
# Print info about xrdp Xvnc sessions
#

RED=$(tput setaf 1; tput bold) #"\033[1;31m"
GREEN=$(tput setaf 2; tput bold) #"\033[1;32m"
YELLOW=$(tput setaf 3; tput bold)
ENDCOLOR=$(tput sgr0) #"\033[0m"
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Format string for printf
_printf="%7s %-20s %-19s %-10s %4s %-12s\n"

# Print header
printf "\n${_printf}" PID USERNAME START_TIME GEOMETRY BITS STATUS

ps h -C Xvnc -o user:20,pid,lstart,cmd | while read username pid dt1 dt2 dt3 dt4 dt5 xvnc_cmd; do
    timestring="${dt1} ${dt2} ${dt3} ${dt4} ${dt5}";
    start_time_s=$(date -d "${timestring}" +"%s");
    printf -v start_time "%(%Y-%m-%d %H:%M)T" ${start_time_s}
    [ ${start_time_s} -lt $(date -d "-30 days" +%s) ] && start_time="${YELLOW}${start_time}${ENDCOLOR}"
    read geometry colorbits <<< $(echo ${xvnc_cmd} | awk '{for(i=i;i<=NF;i++){if($i=="-geometry"){geom=$(++i)} if($i=="-depth"){bits=$(++i)}} print geom,bits}');
    ss -tep 2>/dev/null | grep -q pid\=${pid}, && status="${GREEN}active${ENDCOLOR}" || status="${RED}disconnected${ENDCOLOR}";
    printf "${_printf}" ${pid} ${username} "${start_time}" ${geometry} ${colorbits} "${status}";
done
echo ""
