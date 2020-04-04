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

# handle command line arguments
args=`getopt r: $*`
if [ $? -ne 0 ]; then
        echo 'usage: j [-r rating] [msg...]'
        exit 2
fi
set -- $args

# get variables for arguments
rating=""
while [ $# -ne 0 ]
do
	case "$1" in
		-r) rating="$2"; shift;;
		--) shift; break;;
	esac
	shift
done

# handle the entry
if [ -z "$*" ]; then
	# no arguments, go to the editor
	echo $*
	$editor $tmpfile
else
	# text was specified as arguments
	echo $* >>$tmpfile
fi

# indent the body of the entry by two spaces
sed -i 's/^/  /g' $tmpfile

# prepend the timestamp and metadata-- if we had done this before, it would be visible in the editor
metadata=""
if [ ! -z $rating ]; then
	metadata=" rating: $rating"
fi
echo "[$now]$metadata\n$(cat $tmpfile)" > $tmpfile

# append the entry to the actual journal file
(
	# prepend the date if it's the first entry for the day
	if ! [ "$today" = "$lastdate" ]; then
		echo
		echo $today
	fi

	# and a newline
	echo

	# indent everything
	sed 's/^/    /g' <$tmpfile
)>>$journal
