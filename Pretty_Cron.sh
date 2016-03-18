#!/bin/bash

#manual path to cronfile or it'll read every cron file
if [[ -n $1 ]]; then
	cronfile=$1
else
	cronfile=$(find /var/spool/cron -type f)
fi

function Range_Convert {
	#changes dashes to .. for bracket expansion and comma's to open/close brackets to allow more expansions .. then changes all back to comma seperated.
	Range_Var=$(eval echo $(echo "{${Range_Var}}" | sed -e 's/-/../g' -e 's/,/} {/g') | tr ' ' ',' )
}

function Pretty_Time {
unset prettymin prettyhour prettytime temphour tempmin

if [[ ${min} = "*" ]]; then
	prettymin="Every Minute"
elif [[ ${min} -eq 0 ]] ;then
	prettymin=":00"
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
		temphour="${temphour}${i}${prettymin} "
	done
	prettytime="${temphour}"
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
unset prettymonth tempmonth
MONTHS=(ZERO Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

if [[ $(echo "${Month}" | grep "-") ]] ; then  
	Range_Var=${Month}
	Range_Convert
	Month=${Range_Var}
fi

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
	if [[ ${#d} -eq 1 ]] || [[ ${d} -eq 11 ]] || [[ ${d} -eq 12 ]] || [[ ${d} -eq 13 ]] ;then
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
unset prettydow prettydom prettydays tempdow tempdom
DAYS=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

#Parse Ranges to comma seperated
if [[ $(echo "${DoW}" | grep "-") ]] ; then  
	Range_Var=${DoW}
	Range_Convert
	DoW=${Range_Var}
fi
if [[ $(echo "${DoM}" | grep "-") ]] ; then  
	Range_Var=${DoM}
	Range_Convert
	DoM=${Range_Var}
fi

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


#Start of read loops
for crons in ${cronfile}; do
	cat ${crons} | egrep -v "^#|^$"| while read min hour DoM Month DoW CMD; do 
		export crontime=$(printf "%s %s %s %s %s\n" "$min" "$hour" "$DoM" "$Month" "$DoW") 
		usernm=$(echo $crons | awk -F"cron/" '{print $2}')
		
		Pretty_Time
		Pretty_Month
		Pretty_Days

		echo ""
		echo "CronTime is ${crontime}" 
		echo "${prettytime}${prettyhour}${prettymin} ${prettydays}${prettydow} ${prettydom} ${prettymonth}" | sed -e 's/  / /g' -e 's/^ //'
	done #End of While Read Loop
done #End of for Loop
