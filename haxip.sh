#!/bin/bash

COUNT=-1
KEEPLOG=-1
IFACE=''
OPT_FULL=false
OPT_NOHEADINGS=false
OPT_COPY=false

function main() {
	parsed_args=$(getopt -o c:I:fk:nCh -l count:,iface:,keeplog:,full,noheadings,copy,help -n 'haxip' -- "$@")
	getopt_exit_code=$?
	captured_data_location=$(mktemp)
	
	[ $getopt_exit_code -ne 0 ] && exit 1

	eval set -- "$parsed_args"

	while :; do
		case "$1" in
			-k | --keeplog ) KEEPLOG="$2"; shift 2 ;;
			-c | --count ) COUNT="$2"; shift 2 ;;
			-I | --iface ) IFACE="$2"; shift 2 ;;
			-f | --full ) OPT_FULL=true; shift 1 ;;
			-n | --noheadings ) OPT_NOHEADINGS=true; shift 1 ;;
			-C | --copy ) OPT_COPY=true; shift 1 ;;
			-h | --help ) show_help; exit 1 ;; 
			-- ) shift; break ;;
			* ) break ;;
		esac
	done

	[ "$EUID" -ne 0 ] && err 'you must be root to execute this command'
	[ "$KEEPLOG" -eq "$KEEPLOG" ] 2>/dev/null || err 'keeplog must be a number'
	[ "$KEEPLOG" -lt -1 ] && err 'keeplog must be equal or greater than -1'
	[ "$COUNT" -eq "$COUNT" ] 2>/dev/null || err 'count must be a number'
	[ "$COUNT" -eq 0 ] && err 'count must be -1 or a positive integer'
	[ "$COUNT" -lt -1 ] && err 'count must be -1 or a positive integer'
	[ -z "$IFACE" ] && err 'you must specify an interface'
	ip addr show "$IFACE" 2>/dev/null>&2 || err 'network interface does not exist'

	trap hinterrupt SIGINT

	$OPT_NOHEADINGS || ($OPT_FULL && show_full_header || show_short_header)

	pending=$COUNT

	while [ $pending -ne 0 ]; do
		[ $pending -ne -1 ] && pending=$(($pending-1))
		ip=$(capture_unique)
		$OPT_FULL && show_full_info "$ip" || show_short_info "$ip"
		$OPT_COPY && printf "%s" "$ip" | xclip -i -sel clipboard
	done

	[ -f "$captured_data_location" ] && rm "$captured_data_location"
}

function show_help() {
	echo Usage: haxip [ -fnCh ] [ -k keeplog ] [ -c count ] [ -I interface ]
	echo Options are:
	echo '     -k | --keeplog                 discard ips included in the set of the last N ips logged'
	echo '     -c | --count                   stop after displaying N entries'
	echo '     -I | --iface                   set which network interface to sniff on'
	echo '     -f | --full                    display ip, geolocation and timestamp'
	echo '     -n | --noheadings              do not display column headings'
	echo '     -C | --copy                    copy the last ip to the clipboard'
	echo '     -h | --help                    display this message and exit'
}

function err() {
	printf "haxip: error: %s\n" "$1" >&2
	exit 1
}

function hinterrupt() {
	[ -f "$captured_data_location" ] && rm "$captured_data_location"
	exit 1
}

function regexfmt() {
	read line;
	printf '(^%s' "$line";
	while read line; do
		printf '$)|(^%s' "$line"
	done;
	printf '$)\n'
}

function capture() {
	ipv4s="$(ip -4 addr show "$IFACE" | grep -Eo 'inet (([0-9]+)\.){3}[0-9]+' | cut -d' ' -f2 | regexfmt)"
	ipv6s="$(ip -6 addr show "$IFACE" | grep -Eo 'inet6 ([a-f0-9]+:){7}[a-f0-9]+' | cut -d' ' -f2 | regexfmt)"

	while [ -z "$captured" ] ; do
		captured="$(tshark -i "$IFACE" -e ipv6.src -e ipv6.dst -e ip.src -e ip.dst -Tfields -Y 'dtls' -c1 2>/dev/null | tr '\t' '\n')"
	done

	echo "$captured" | grep -E -ve "(^$)|${ipv4s}|${ipv6s}"
}

function capture_unique() {
	recent_capture=$(capture)

	while grep -iq "$recent_capture" "$captured_data_location"; do
		recent_capture=$(capture)
	done
	
	echo $recent_capture >> $captured_data_location

	if [ "$KEEPLOG" -ne -1 ] ; then
		lines=$(tail -$KEEPLOG "$captured_data_location")
		printf "%s\n" "$lines" > $captured_data_location
	fi

	echo $recent_capture
}

function show_full_header() {
	printf "%-40s %-10s %-15s %-25s %-20s\n" IP CODE COUNTRY CITY TIMESTAMP
}

function show_short_header() {
	printf "%-40s\n" IP
}

function show_full_info() {
	ip="$1"

	ipdata="$(curl -s http://ip-api.com/json/$ip)"
	country="$(echo "$ipdata" | jq '.country' | tr -d '"')"
	city="$(echo "$ipdata" | jq '.city' | tr -d '"')"
	code="$(echo "$ipdata" | jq '.countryCode' | tr -d '"')"
	timestamp="$(date +"%H:%M:%S")"

	printf "%-40s %-10s %-15s %-25s %-20s\n" "$ip" "$code" "$country" "$city" "$timestamp"
}

function show_short_info() {
	ip="$1"
	printf "%s\n" "$ip"
}

main "$@"
