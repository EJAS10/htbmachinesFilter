#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){	
 echo -e "Saliendo..."
 tput cnorm && exit 1
}
#Ctrl+C
trap ctrl_c INT

#variables
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel() {
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} uso:${endColour}"
	echo -e "\t${purpleColour}m)${endColour} Buscar por un nombre de maquina"
	echo -e "\t${purpleColour}u)${endColour} Actualizar Documento local"
	echo -e "\t${purpleColour}i)${endColour} Buscar por IP de la maquina"
	echo -e "\t${purpleColour}y)${endColour} Abrir Link en el navegador"
	echo -e "\t${purpleColour}d)${endColour} Buscar por dificulta"
	echo -e "\t\t${greenColour}0)${endColour} Facil"
	echo -e "\t\t${greenColour}1)${endColour} Media"
	echo -e "\t\t${greenColour}2)${endColour} Dificil"
	echo -e "\t\t${greenColour}3)${endColour} Insane"
	echo -e "\t${purpleColour}o)${endColour} Buscar por Sistema operativo"
	echo -e "\t\t${greenColour}w)${endColour} Windows"
	echo -e "\t\t${greenColour}l)${endColour} Linux"
	echo -e "\t${purpleColour}h)${endColour} Help"
}

function updateFiles(){
	tput civis
	if [ ! -f bundle.js ]; then	
		echo "Creando archivos necesarios"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo "Archivo necesarios ha sido creado"
	else
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_Value=$(md5sum bundle_temp.js | awk '{print $1}')
		echo $md5_temp_Value
		md5_original_Value=$(md5sum bundle.js | awk '{print $1}')
		echo $md5_original_Value
		
		if [ "$md5_original_Value" == "$md5_temp_Value" ]; then 
			echo "No hay actualizaciones"
			rm bundle_temp.js
		else
			echo "Actualizando"
			rm bundle.js && mv bundle_temp.js bundle.js
		fi
	fi
	tput cnorm
}

function searchMachine(){
	tput civis
	machineName=$1
	machineResult=$(cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/")
	if [ "$machineResult" ]; then
		cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d ',' |  tr -d '"' | sed 's/^ *//'		
	else
		echo -e "\n${redColour}[!]${endColour} La maquina ($machineName) no fue encontrada"
	fi
	tput cnorm
}

function searchMachineByIP(){
	tput civis
	machineIp=$1
	machineName="$(cat bundle.js | grep "ip: \"$machineIp\"" -B 3 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}')"
	if [ "$machineName" ]; then		
		echo -e "\n ${greenColour}[+]${endColour} La maquina correspondiente para la ip ${redColour}$machineIp${endColour} es ${redColour}$machineName${endColour} \n ${greenColour}Buscando...${endColour}"
		searchMachine $machineName
	else
		echo -e "\n${redColour}[!]${endColour} La IP ($machineIp) no fue encontrada"
	fi
	tput cnorm
}

function OpenYoutubeLinkMachine(){
	tput civis
	_machineName=$1
	youtubeLink=$(cat bundle.js | awk  "/name: \"$_machineName\"/,/resuelta:/" | grep youtube | tr -d ',' |  tr -d '"' | sed 's/^ *//' | awk 'NF{print $NF}')
	if [ "$youtubeLink" ]; then				
		echo -e "\n${greenColour}[+]${endColour} Abriendo Link de youtube${blueColour} $youtubeLink ${endColour}"
		/usr/bin/firefox $youtubeLink & disown
	else
		echo -e "\n${redColour}[!]${endColour} El link o la maquina en si ($machineName) no fue encontrada"
	fi
	tput cnorm
}

function FindByDifficulty(){	
 	 case $1 in
   	   0) difficulty=Fácil;;
   	   1) difficulty=Media;;
   	   2) difficulty=Difícil;;
   	   3) difficulty=Insane;;
	   *) difficulty=$1;;
	 esac

	echo -e "${greenColour}[+]${endColour} Buscando la dificulta ($difficulty)\n"
	difficulty_Result=$(cat bundle.js | grep "dificultad: \"$difficulty\"")
	if [ "$difficulty_Result" ]; then
		echo -e "\n [+] Representando las maquinas con la dificulta $difficulty:\n"
		cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column		
	else
		echo -e "\n [!] La dificulta ($difficulty) no existe"
	fi
	
}

function FindByOS(){	
 	 case $1 in
   	   w) os=Windows;;
   	   l) os=Linux;;
	   *) os=$1;;
	 esac

	echo -e "${greenColour}[+]${endColour} Buscando el Sistema operativo ($os)\n"
	os_Result=$(cat bundle.js | grep "so: \"$os\"")
	if [ "$os_Result" ]; then
		echo -e "\n [+] Representando las maquinas con el sistema $os:\n"
		cat bundle.js | grep "so: \"$os\"" -B 5 | grep name | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column		
	else
		echo -e "\n [!] El sistema ($os) no existe"
	fi
	
}

function FindByOSandDifficulty(){
	_os=$1
	_difficulty=$2
 	 case $_os in
   	   w) os=Windows;;
   	   l) os=Linux;;
	   *) os=$1;;
	 esac
 	 case $_difficulty in
   	   0) difficulty=Fácil;;
   	   1) difficulty=Media;;
   	   2) difficulty=Difícil;;
   	   3) difficulty=Insane;;
	   *) difficulty=$1;;
	 esac
	 echo -e "${greenColour}[+]${endColour} Buscando el Sistema operativo ($os) y la dificulta ($difficulty)\n"
	os_Result=$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"")
	if [ "$os_Result" ]; then
		echo -e "\n [+] Representando las maquinas con el sistema $os y la dificultad $difficulty:\n"
		cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:"| awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column		
	else
		echo -e "\n [!] El sistema ($os) o la dificultad ($difficulty) no existen"
	fi
}

#indicadores
declare -i parameter_counter=0
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:u:i:y:d:o:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
    h) ;;
  esac
done


if [ $parameter_counter -eq 1 ]; then 
   searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
   updateFiles
elif [ $parameter_counter -eq 3 ]; then
   searchMachineByIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
   OpenYoutubeLinkMachine $machineName
elif [ $parameter_counter -eq 5 ]; then
   FindByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
   FindByOS $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
   FindByOSandDifficulty $os $difficulty
else
   helpPanel
fi
