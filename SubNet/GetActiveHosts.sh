#!/bin/bash

function ctrl_c(){	
 echo -e "Saliendo..."
 tput cnorm; exit 1
}
#Ctrl+C
trap ctrl_c SIGINT

tput civis
# for host in $(seq 1 254); do
#    timeout 1 bash -c "ping -c 1 192.168.1.$1" &>/dev/null && echo "[+] Host 192.168.1.$1 - ACTIVE" &
# done

for host in $(seq 1 254); do
    timeout 1 bash -c "ping -c 1 192.168.1.$host" &>/dev/null && echo "[+] Host 192.168.1.$host - ACTIVE by ping" &
    for port in 21 22 23 25 80 139 443 445 8080; do
        timeout 1 bash -c "echo '' >  /dev/tpc/192.168.1.$host/$port" 2>/dev/null && echo "[+] Host 192.168.1.$host - Port ($port) " &
    done
done
wait

tput cnorm