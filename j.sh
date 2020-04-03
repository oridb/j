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
if [ -z "$*" ]; then
	echo $*
	$editor $tmpfile
else
	echo $* >$tmpfile
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
