#!/bin/bash

clear
echo -e "Logins/Passwords/IP"
if [ -f "/root/cyber_node/all_logins.txt" ] && [ -s "/root/cyber_node/all_logins.txt" ]; then
    tail -n 20 /root/cyber_node/all_logins.txt
else
    echo "None"
fi

echo -e "the lastest writen commands"

if [ -f "/root/cyber_node/all_commands.txt" ] && [ -s "/root/cyber_node/all_commands.txt" ]; then

    tail -n 15 /root/cyber_node/all_commands.txt | awk '{
        if (length($0) > 95) print substr($0, 1, 92) "..."
        else print $0
    }'
else
    echo "None"
fi
echo ""
