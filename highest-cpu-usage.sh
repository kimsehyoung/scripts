#!/bin/bash

CPU_REALTIME_FILE="realtime_highest_cpu_usage.txt"
CPU_RECORD_FILE="highest_cpu_usage.txt"
MAX_CPU_USAGE=0.0
INTERVAL=3s

handle_signal() {
	EXIT_STATUS=$?
	if [ -f ${CPU_REALTIME_FILE} ]; then
    	rm ${CPU_REALTIME_FILE}
	fi

    if [ "$1" == "SIGINT" ]; then
        trap - EXIT
		echo -e "[$(date +%Y.%m.%d-%H:%M:%S)] The highest cpu usage is ${MAX_CPU_USAGE}% until now (Ctrl+C)"
        exit 130
    elif [ ${EXIT_STATUS} == 0 ]; then
		echo -e "[$(date +%Y.%m.%d-%H:%M:%S)] The highest cpu usage is ${MAX_CPU_USAGE}% for ${DURATION}." | tee -a ${CPU_RECORD_FILE}
    else
		echo -e "Error ${EXIT_STATUS}"
    fi
}
trap 'handle_signal EXIT' EXIT
trap 'handle_signal SIGINT' SIGINT

help() {
	echo -e "This measures the highest cpu usage during a specific duration on a linux host. (Interval: ${INTERVAL})"
	echo -e "Options:"
	echo -e "-d, --duration\n\tDuration to measure cpu usage\n\tunit: s, m, h, d\n"
	exit 1
}

parse_arguments() {
	OPTIONS=$(getopt -n $0 -o i:d: --long interval:duration: -- "$@")
	VALID_ARGUMENTS=$?
	if [ "$VALID_ARGUMENTS" != "0" ]; then
		help
	fi
	eval set -- "$OPTIONS"

	while :
	do
		case "$1" in
			-d | --duration) DURATION=$2	; shift 2 ;;
			--) shift; break ;;
			*) echo "Unexpected option: $1"
			   help ;;
	   esac
	done

	if [[ -z ${DURATION} ]]; then
		echo -e "Error: must specify 'duration' arguments\n"
		help
	fi


	if ! [[ ${DURATION} =~ ^[0-9]+[smhd]$ ]]; then
		echo "-d, --duration: is not valid. e.g. 5s, 1m, 2h, 1d ..."
		exit 1
	fi
}

measure_cpu_usage() {
	case ${DURATION} in
		*s)
			COUNT=$((${DURATION/s}/${INTERVAL/s}))
			;;
		*m)
			COUNT=$((${DURATION/m}*60/${INTERVAL/s}))
			;;
		*h)
			COUNT=$((${DURATION/h}*60*60/${INTERVAL/s}))
			echo "hours"
			;;
		*d)
			COUNT=$((${DURATION/d}*60*60*24/${INTERVAL/s}))
			;;
		*)
			echo "Unknown duration: ${DURATION}"
			exit 1
			;;
	esac

	for (( i=0; i<$COUNT; i++ ))
	do
    	CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
		if [[ $(echo "${CPU_USAGE} > ${MAX_CPU_USAGE}" | bc) -eq 1 ]]; then
			MAX_CPU_USAGE=${CPU_USAGE}
			echo -e "[$(date +%Y.%m.%d-%H:%M:%S)] The highest cpu usage is ${MAX_CPU_USAGE}% for ${DURATION}." > ${CPU_REALTIME_FILE}
		fi
		sleep ${INTERVAL}
	done
}

parse_arguments $@
measure_cpu_usage