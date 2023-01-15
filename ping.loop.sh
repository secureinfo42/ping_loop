#!/bin/sh

trap exit sigint

if [ $# -gt 3 -o "$*" = "-h" ]; then
	echo "
Usage: $(basename $0) [-h | [host] [delay] [break] ]

Loop ICMP request to host with delay (in s)

If break set to 1, then script will abort if host is alive
If break set to -1, then script will abort if host is dead

"
	exit 0
fi

host="www.google.com" ; [ $# -ge 1 ] && host="$1"
sleep=2 ; [ $# -ge 2 ] && sleep="$2"
dobreak=0 ;  [ $# -eq 3 ] && dobreak="$3"

while true ; do

	err=0
	now=$(date)
	res=$(ping -t 2 -c 1 "$host" 2>&1)
	err=$?

	if [ $err -eq 68 ] ; then
		msg="$now - unable to resolve '$host'"
	fi
	if [ $err -eq 0 ] ; then
		res="$(echo "$res"|grep icmp_seq)"
		msg="$now - \033[1;32m$res\033[0m"
		if [ "$dobreak" = "1" ]; then
			echo "$msg"
			sleep 1
			printf "\033[1;34mHost is up, so loop breaks.\n\033[0m"
			break
		fi
	fi

	if [ $err -eq 1 ] ; then
		msg="$now - \033[1;33mICMP packet not sent\033[0m"
	fi

	if [ $err -eq 2 ] ; then
		msg="$now - \033[1;31mno ICMP reply\033[0m"
		if [ "$dobreak" = "-1" ]; then
			echo "$msg"
			sleep 1
			printf "\033[1;34mHost is down, so loop breaks.\n\033[0m"
			break
		fi
	fi

	echo "$msg"

	for i in $(seq 1 $sleep) ; do printf "\033[0;30m\rWaiting for \033[0m$((sleep-i+1))\033[0;30ms...\033[0m" ; sleep 1 ; done
	printf "\r%40s" " "
	printf "\r"
done


