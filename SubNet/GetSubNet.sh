#!/bin/bash

calculate_subnet_mask() {
    local cidr="$1"
    local mask=""
    for (( i=0; i<32; i++ )); do
        if (( i < cidr )); then
            mask+="1"
        else
            mask+="0"
        fi
    done
    echo "$((2#${mask:0:8}))"."$((2#${mask:8:8}))"."$((2#${mask:16:8}))"."$((2#${mask:24:8}))"
}

calculate_total_hosts() {
    local cidr="$1"
    echo "$((2**(32-cidr))-2)"
}

if [[ $# -ne 2 ]]; then
    echo "Uso: $0 <ip_address> <CIDR>"
    exit 1
fi

ip_address="$1"
cidr="$2"

if ! [[ "$ip_address" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Dirección IP inválida."
    exit 1
fi

if ! [[ "$cidr" =~ ^[0-9]+$ ]] || (( cidr < 0 || cidr > 32 )); then
    echo "Notación CIDR inválida."
    exit 1
fi

subnet_mask=$(calculate_subnet_mask "$cidr")

IFS='.' read -r -a ip_parts <<< "$ip_address"
IFS='.' read -r -a mask_parts <<< "$subnet_mask"
network_address=""
for (( i=0; i<4; i++ )); do
    network_address+="$(( ${ip_parts[$i]} & ${mask_parts[$i]} ))"
    if (( i < 3 )); then
        network_address+="."
    fi
done

broadcast_address=$(ipcalc -nb "$ip_address/$cidr" | grep -i 'broadcast' | cut -d'=' -f2 | awk '{print $1}')

first_address="${network_address%.*}.1"
last_address="${network_address%.*}.254"

total_hosts=$(calculate_total_hosts "$cidr")

# Mostrando resultados
echo "Dirección de red (Network ID): $network_address"
echo "Dirección de broadcast (Broadcast Address): $broadcast_address"
echo "Máscara de subred: $subnet_mask"
echo "Rango de direcciones IP: $first_address - $last_address"
echo "Número total de hosts: $total_hosts"

echo "--------------------------------------------------------"
echo "CIRD 1-8 sin clase Subnet x.0.0.0"
echo "CIRD 9-16 Clase A Subnet 255.x.0.0"
echo "CIRD 17-24 Clase B Subnet 255.255.x.0"
echo "CIRD 25-32 Clase C Subnet 255.255.255.x"