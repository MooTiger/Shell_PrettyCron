#specify cronfile to read
cronfile=/var/spool/cron/root

function Pretty_Time {
prettymin=
prettyhour=
prettytime=

if [[ ${min} = "*" ]]; then
	prettymin="Every Minute"
elif [[ ${min} -eq 0 ]]; then 
	prettymin="00"
else
	prettymin=${min}
fi

if [[ ${hour} = "*" ]]; then
	prettyhour="of Every Hour"
elif [[ ${hour} -eq 0 ]]; then 
	prettyhour="00"
else
	prettyhour=${hour}
fi

if [[ $(echo ${hour} | awk '/,/') ]] && [[ $(echo ${min} | awk '/,/') ]]; then
	for i in $(echo ${hour} | tr ',' ' ');do
		for m in $(echo ${min} | tr ',' ' '); do
			temptime="${i}:${m}"
			prettytime="${prettytime} ${temptime}"
		done
#	temphour="${temphour}:${prettymin} ${i}"
#	temphour=$(echo ${temphour} | sed 's/^:..//')
	done
	prettymin=
	prettyhour=
elif [[ $(echo ${hour} | awk '/,/') ]]; then
	for i in $(echo ${hour} | tr ',' ' ');do
		temphour="${temphour}:${prettymin} ${i}"
		temphour=$(echo ${temphour} | sed 's/^:..//')
	done
	prettytime="${temphour}:${prettymin}"
	prettymin=
	prettyhour=
elif [[ $(echo ${min} | awk '/,/') ]]; then
	for i in $(echo ${min} | tr ',' ' '); do
		tempmin="${prettyhour}:${i}"
		prettytime="${prettytime} ${tempmin}"
	done
	prettymin=
	prettyhour=
fi	
}

function Pretty_Month {
prettymonth=
MONTHS=(ZERO Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
if [[ ${Month} = "*" ]]; then
	prettymonth="of Every Month"
elif [[ $(echo ${Month} | awk '/,/') ]] ; then
	for i in $(echo ${Month} | tr ',' ' ') ; do
		tempmonth="${tempmonth} ${MONTHS[${i}]}"
	done
	prettymonth="In ${tempmonth}"
else
	prettymonth="In ${MONTHS[${Month}]}"
fi
}

function Pretty_DoW {
prettydow=
prettydom=
DAYS=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

if [[ ${DoW} = "*" ]] && [[ ${DoM} = "*" ]]; then
	prettydow="Every Day"
elif [[ $(echo ${DoW} | awk '/,/') ]] ; then
	for i in $(echo ${DoW} | tr ',' ' ') ; do
		tempdow="${tempdow} ${DAYS[${i}]}"
	done
	prettydow="On the weekdays${tempdow}"
elif [[ ${DoM} != "*" ]] && [[ ${DoW} = "*" ]];then
	prettydom="on the ${DoM} of"
elif [[ ${DoW} != "*" ]] && [[ ${DoM} != "*" ]];then
	prettydom="on ${DAYS[${DoW}]} the ${DoM}"
else
	prettydow="On ${DAYS[${DoW}]}"
fi
}


#Start of while read loop
cat ${cronfile} | while read min hour DoM Month DoW CMD; do 
	export crontime=$(printf "%s %s %s %s %s\n" "$min" "$hour" "$DoM" "$Month" "$DoW") 


	Pretty_Time
	Pretty_Month
	Pretty_DoW

	echo "we run ${CMD}"
	echo "CronTime is ${crontime}" #Just to see what the input fields were
	echo "${prettytime}${prettyhour} ${prettymin} ${prettydow} ${prettydom} ${prettymonth}"

done #End of While Read Loop
