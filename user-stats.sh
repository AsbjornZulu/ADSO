#!/bin/bash

echo "Resum de logins:"
for user_name in $(cat /etc/passwd | cut -d : -f1);do
	numlogs=0
	days=0
	hours=0
	minutes=0

	#echo $user_name
	for login in $(last -F $user_name | grep '(' | cut -d '(' -f2 |cut -d ')' -f1);do
		numlogs=$(($numlogs + 1)) # numlogs sera el contador de logins
		#Calculador de dias, dias que ha estado logeado el user
		day=$(echo $login | grep + | cut -d + -f1)
		numDay=${#day}
		if [ $numDay -ne 0 ]; then
			if echo "$day" | egrep -q '^\-?[0-9]+$'; then
				days=$(expr $days + $day)
			fi
		fi
		
		#Calculador de horas, horas que ha estado logeado el user
		hour=$(echo $login | cut -d + -f2 | cut -d : -f1)
		numHour=${#hour}
		if [ $numHour -ne 0 ]; then
			if echo "$hour" | egrep -q '^\-?[0-9]+$'; then
				hours=$(expr $hours + $hour)
			fi
		fi
		
		#Calculador de minutos, minutos dque ha estado logeado el user
		minute=$(echo $login | cut -d ':' -f2)
		numMinute=${#minute}
		if [ $numMinute -ne 0 ]; then
			if echo "$minute" | egrep -q '^\-?[0-9]+$'; then
				minutes=$(expr $minutes + $minute)
			fi
		fi
	done
	
	#Convertimos las horas y dias a minutos y sumamos todo
	minutes=$(($minutes+($hours*60)))

	if [ $minutes -ne 0 ]; then
		echo "Usuari $user_name: temps total de login $minutes min, nombre total de logins: $numlogs"
	fi

done


echo -e ""
echo "Resum d'usuaris connectats"

for user_name in $(cat /etc/passwd | cut -d : -f1);do
	numProcesos=`ps aux | grep $user_name | wc -l`
	#Con el comando awk lo que hacemos es coger la 3ra columna y hacer un sumatorio de todas las filas de esta columna
	cpu=`ps aux | grep $user_name | awk 'NR>2{arr[1]+=$3}END{for(i in arr) print arr[1]}' `
	if echo "$cpu" | egrep -q '^\-?[0-9]+$'; then
		if [ $cpu -ne 0 ]; then
			echo "Usuari $user_name: $numProcesos processos -> $cpu% CPU"
		fi
	fi
done
