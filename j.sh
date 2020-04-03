#!/bin/sh

set -x

# default editor to vi
if [ -z "$EDITOR" ]; then
	editor=vi
else
# otherwise use the system editor
	editor=$EDITOR
fi

# file references
journal=$HOME/journal
tmpfile=/tmp/j.$$

# file handling
trap "rm -f $tmpfile" EXIT
touch $tmpfile

# date variables
today=$(date -I)
now=$(date -Iseconds)
lastdate=$(grep '^[0-9]' $journal | tail -n 1)

# regex for matching rational entry ratings in the range [0, 7)
# these have to be the first argument in the command line or the first line in the entry
ratingregex="^[0-6]\.[0-9]*$"

# handle the entry
if [ -z "$*" ]; then
	# no arguments, go to the editor
	echo $*
	$editor $tmpfile
else
	# text was specified as arguments
	# if the first argument is a rating, prepend it to the temp file
	if [ $# -gt 1 -a $(expr "$1" : ^[0-7]$) -gt 0 -o $(expr "$1" : $ratingregex) -gt 0 ]
	then
		echo $1 >>$tmpfile
		shift
	fi
	# echo remaining arguments into the temp file
	echo $* >>$tmpfile
fi

# prepend the timestamp -- if we did this before, it would be visible in the editor
if [ "$today" = "$lastdate" ]; then
	echo "$now\n$(cat $tmpfile)" > $tmpfile
fi

# append the entry to the actual journal file
(
	# prepend the date if it's the first entry for the day
	if ! [ "$today" = "$lastdate" ]; then
		echo $today
	fi

	# and a newline
	echo

	# indent everything
	sed 's/^/    /g' <$tmpfile
)>>$journal
