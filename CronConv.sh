#!/bin/bash


cronfile=/var/spool/cron/root


function Pretty_Time {
prettymin=
prettyhour=
prettytime=

if [[ ${min} = "*" ]]; then
	prettymin="Every Minute"
#elif [[ ${min} -eq 0 ]]; then 
	#prettymin=":00"
else
	prettymin=":${min}"
fi

if [[ ${hour} = "*" ]]; then
	prettyhour="of Every Hour"
elif [[ $(echo ${hour} | wc -m ) -le 2 ]]; then 
	prettyhour="0${hour}"
else
	prettyhour=${hour}
fi

if [[ $(echo ${hour} | awk '/,/') ]] && [[ $(echo ${min} | awk '/,/') ]]; then
	for i in $(echo ${hour} | tr ',' ' ');do
		for m in $(echo ${min} | tr ',' ' '); do
			temptime="${i}:${m}"
			prettytime="${prettytime} ${temptime}"
		done
	done
	prettymin=
	prettyhour=
elif [[ $(echo ${hour} | awk '/,/') ]]; then
	for i in $(echo ${hour} | tr ',' ' ');do
		temphour="${temphour}:${prettymin} ${i}"
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
tempmonth=
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

function Split_DoM {

for d in $(echo ${i}); do
	if [[ ${#d} -eq 1 ]] ;then
		Digit=${d}
		F_Suffix
	else
		Digit=$(echo ${d#[0-9]})
		F_Suffix
	fi
done
}

function F_Suffix {

case ${Digit} in
	1) suffix="st" ;;
	2) suffix="nd" ;;
	3) suffix="rd" ;;
	*) suffix="th" ;;
esac
}

function Pretty_Days {
prettydow=
prettydom=
prettydays=
DAYS=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)







if [[ ${DoW} = "*" ]] && [[ ${DoM} = "*" ]]; then
	prettydow="Every Day"
elif [[ $(echo ${DoW} | awk '/,/') ]] && [[ $(echo ${DoM} | awk '/,/') ]]; then
	for i in $(echo ${DoW} | tr ',' ' ') ; do
		tempdow="${tempdow} ${DAYS[${i}]}"
	done
	for i in $(echo ${DoM} | tr ',' ' ') ; do
		Split_DoM
		tempdom="${tempdom} ${i}${suffix}"
	done
	prettydays="on ${tempdow} and the ${tempdom}"

elif [[ $(echo ${DoW} | awk '/,/') ]] ; then
	for i in $(echo ${DoW} | tr ',' ' ') ; do
		tempdow="${tempdow} ${DAYS[${i}]}"
	done
	prettydow="On the weekdays${tempdow}"
elif [[ ${DoW} = "*" ]] && [[ ${DoM} != "*" ]]; then
	prettydom="on the ${DoM} of"
	Split_DoM
elif [[ ${DoW} != "*" ]] && [[ ${DoM} != "*" ]]; then
	prettydom="on ${DAYS[${DoW}]} and the ${DoM}${suffix}"
	Split_DoM
else
	prettydow="On each ${DAYS[${DoW}]}"
fi

}




#Start of while read loop
cat ${cronfile} | while read min hour DoM Month DoW CMD; do 
	export crontime=$(printf "%s %s %s %s %s\n" "$min" "$hour" "$DoM" "$Month" "$DoW") 
	
	Pretty_Time
	Pretty_Month
	Pretty_Days

	echo "We Run ${CMD}"
	echo "CronTime is ${crontime}" 
	echo "${prettytime}${prettyhour}${prettymin} ${prettydays}${prettydow} ${prettydom} ${prettymonth}" | sed -e 's/  / /g' -e 's/^ //' -e 's/:0/:00/g'

done #End of While Read Loop
