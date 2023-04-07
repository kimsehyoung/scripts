#!/bin/bash

# https://www.shellscript.sh/examples/getopt/

help() {
	echo -e "This measures the highest memory usage during a specific duration on a linux host."
	echo -e "Options:"
    echo -e "-i, --interval\n\tInterval in seconds to measure memory usage\n\tunit: s\n"
    echo -e "-d, --duration\n\tDuration to measure memory usage\n\tunit: s, m, h, d\n"

	exit 1
}

parse_arguments() {
	# -n option is used to set the name of the program or script that is using getopt.
	# -o is for short options
	# colon (:) to indicate that an argument expects a value, like "-n sehyoung"
	# -- is used to signal the end of options and the beginning of positional parameters.
	# $@ is all command line parameters passed to the script.
	OPTIONS=$(getopt -n $0 -o i:d: --long interval:duration: -- "$@")
	# $? is that containts the exit status of the most recently executed foreground pipeline.
	VALID_ARGUMENTS=$?
	if [ "$VALID_ARGUMENTS" != "0" ]; then
		help
	fi
	eval set -- "$OPTIONS"

	while :
	do
		case "$1" in
			-i | --interval) INTERVAL=$2	; shift 2 ;;
			-d | --duration) DURATION=$2	; shift 2 ;;
			--) shift; break ;;
			*) echo "Unexpected option: $1"
			   help ;;
	   esac
	done

	if [[ -z ${INTERVAL} || -z ${DURATION} ]]; then
		echo -e "Error: must specify both 'interval' and 'duration' arguments\n"
		help
	fi

	if ! [[ ${INTERVAL} =~ ^[0-9]+s$ ]]; then
		echo "-i, --interval: is not valid. e.g. 5s, 25s, 100s ..."
		exit 1
	fi

	if ! [[ ${DURATION} =~ ^[0-9]+[smhd]$ ]]; then
		echo "-d, --duration: is not valid. e.g. 5s, 1m, 2h, 1d ..."
		exit 1
	fi
}

measure_memory_usage() {
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

    if [[ ${COUNT} < 1 ]]; then
        echo "The duration '${DURATION}' is less than the interval '${INTERVAL}'"
        echo "The duration must have more than the interval. (e.g. interval: 5s, duration: 1m)"
        exit 1
    fi

	MAX_MEMORY_USAGE=0.0
	for (( i=0; i<$COUNT; i++ ))
	do
		sleep ${INTERVAL}
		MEMORY_USAGE=$(free -h | awk 'NR==2{print $3}' | tr -d [:alpha:][:blank:])
		if [[ $(echo "${MAX_MEMORY_USAGE} > ${MEMORY_USAGE}" | bc) -eq true ]]; then
			MAX_MEMORY_USAGE=${MEMORY_USAGE}
		fi
	done

	echo -e "[$(date +%Y.%m.%d-%H:%M:%S)] The highest memory usage is ${MAX_MEMORY_USAGE}Gi for ${DURATION}." | tee -a memory_usage.txt
}

parse_arguments $@
measure_memory_usage