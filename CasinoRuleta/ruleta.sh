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
	 echo -e "${redColour}[!] Saliendo...${endColour}"
	 tput cnorm && exit 1
}
#Ctrl+C
trap ctrl_c INT

function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} uso:${endColour}"
	echo -e "\t${purpleColour}m)${endColour} Cantidad de dinero con la que se va a jugar"
	echo -e "\t${purpleColour}t)${endColour} tecnica a utilizar"
	echo -e "\t\t${greenColour}> mt${endColour} tecnica Martingala"
	echo -e "\t\t${greenColour}> rl)${endColour} tecnica Reverse Labouchere"
	echo -e "\t${purpleColour}h)${endColour} Help"
}

function MartingalaFt(){

	echo -e "\n${greenColour}[+]${endColour}${grayColour} Dinero Actual:${endColour}${greenColour} $money DOP${endColour}"
	echo -ne "${greenColour}[>]${endColour} Cuanto dinero piensas apostas? -> " && read initial_bet
	echo -ne "${greenColour}[>]${endColour} A que deseas apostas continuamente? \n1) impar, \n2) par \n-> " && read type_bet
	echo -e "\n${greenColour}[+]${endColour}${grayColour} Vamos a jugar con una cantidad inicial de${endColour}${blueColour}: $initial_bet DOP ${endColour}${grayColour} a $type_bet${endColour}"

	initial_bet_backup=$initial_bet
	play_counter=0
	monto_top=0
	before_was_lost=false
	jugadas_malas=""
	tput civis
	while true; do
		if [ $money -le 0 ]; then
			echo -e "${redColour}[!]Te quedaste sin dinero${endColour}" 
			echo -e "${greenColour}[+] Se realizaron ${endColour}${blueColour}$play_counter${endColour}${greenColour} jugadas${endColour}" 
			echo -e "${greenColour}[+] Las secuencia de jugadas perdedoras final son ${endColour}\n${blueColour}[ $jugadas_malas ]${endColour}" 
			echo -e "${greenColour}[+] El monto top fue ${endColour}${blueColour}$monto_top${endColour}" 		
			tput cnorm && exit 0
		fi

		if [ $money -gt $monto_top ]; then		 
			monto_top=$money
		fi

		if [ $money -lt $initial_bet ]; then
			resto=$(($initial_bet-$money))
			echo -e "\n${redColour}[!] No tienes dinero suficiente para la siguiente apuesta, te faltan${endColour} ${blueColour}$resto DOP${endColour}" 
			initial_bet=$(($initial_bet-$resto))
			echo -e "${greenColour}[+]${endColour} La nueva apuesta sera con ${blueColour}$initial_bet DOP${endColour}"		
		fi

		money=$(($money-$initial_bet))
		random_number=$(($RANDOM % 37))
		
		if [ $type_bet -eq 2 ]; then
			if [ $((random_number % 2)) -eq 0 ]; then
				if [ $random_number -eq 0 ]; then
					initial_bet=$(($initial_bet*2))
					jugadas_malas+="$random_number, "
				else 
					reward=$(($initial_bet*2))
					money=$(($money+$reward))
					initial_bet=$initial_bet_backup									
					jugadas_malas=""			
				fi
			else
				initial_bet=$(($initial_bet*2))			
				jugadas_malas+="$random_number, "
			fi
		elif [ $type_bet -eq 1 ]; then
			if [ $((random_number % 2)) -eq 0 ]; then
					initial_bet=$(($initial_bet*2))
					jugadas_malas+="$random_number, "
			else
				reward=$(($initial_bet*2))
				money=$(($money+$reward))			
				jugadas_malas=""
			fi
		else
			echo -e "\n${redColour}[!]${endColour} El typo de apuesta ($type_bet) es incorrecto" 
		fi

		let play_counter+=1
	done
	tput cnorm
}

function RevLabouchereFt(){
	echo "probando labourchere"
}

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
	t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done


if [ $money ] && [ $technique ]; then 
   if [ "$technique" == "mt" ]; then
	MartingalaFt
   elif [ "$technique" == "rl" ]; then
	RevLabouchereFt
	else
	 echo -e "${redColour}[!]${endColour} La tecnica introducida no existe"
	helpPanel
   fi
else
   helpPanel
fi
