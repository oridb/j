#!/bin/sh

set -x

if [ -z "$EDITOR" ]; then
	editor=vi
else
	editor=$EDITOR
fi
journal=$HOME/journal
tmpfile=/tmp/j.$$
trap "rm -f $tmpfile" EXIT
touch $tmpfile
today=$(date -I)
now=$(date -Iseconds)
lastdate=$(grep '^[0-9]' $journal | tail -n 1)
ratingregex="^[0-6]\.[0-9]*$"
if [ -z "$*" ]; then
	echo $*
	$editor $tmpfile
else
	if [ $# -gt 1 -a $(expr "$1" : ^[0-7]$) -gt 0 -o $(expr "$1" : $ratingregex) -gt 0 ]
	then
		echo $1 >>$tmpfile
		shift
	fi
	echo $* >>$tmpfile
fi
if [ "$today" = "$lastdate" ]; then
	echo "$now\n$(cat $tmpfile)" > $tmpfile
fi
(
	if [ "$today" = "$lastdate" ]; then
		echo
	else
		echo $today
	fi
	sed 's/^/   /g' <$tmpfile
)>>$journal
