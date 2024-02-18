#!/bin/bash

function ctrl_c(){	
 echo -e "Saliendo..."
 tput cnorm && exit 1
}
#Ctrl+C
trap ctrl_c SIGINT

declare -a ports=( $(seq 1 65535) )

function checkPort(){
	(exec 3<> /dev/tcp/$1/$2) 2> /dev/null
	if [ $? -eq 0 ]; then
		echo "[+] Puerto $2 abierto"
	fi

	exec 3<&-
	exec 3>&-
}

if [ $1 ]; then
	tput civis
	for port in ${ports[@]}; do
		checkPort $1 $port &
	done
	tput cnorm
else 
echo -e "\n [!] Uso: $0 <ip>\n"
fi

wait