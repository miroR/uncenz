#!/bin/bash
#
# uncenz-syslog-pcap.sh -- chronologically order selected info from the pcap
#                          and the syslog, in a text file
#
# part of uncenz set of scripts
#
# released under BSD license, see LICENSE, or assume general BSD license,
#

function show_help {
  echo "uncenz-syslog-pcap.sh - put together PCAP and syslog for comparison"
  echo ""
  echo "Usage: $0 <PCAP file>"
  echo -e ""
  echo -e "    THIS IS A DRAFT, DON'T KNOW YET HOW RELIABLY IT WORKS"
  echo -e "    NOR IF IT HAS ANY POTENTIAL TO BE A USEFUL SCRIPT SOME DAY"
  echo -e ""
  echo -e "    This is a script that I only checked with PCAP of naming format that"
  echo -e "    a run of uncenz-1st produces, with some variation in the before"
  echo -e "    '.pcap' name ending, i.e. dump_YYMMDD_HHMM_SOMETHING.pcap, such as"
  echo -e "    dump_170311_0328_g0n_arp_udp_notJuniper.pcap"
  echo -e ""
  echo -e "    and a corresponding excerpt from your syslog named by the PCAP,"
  echo -e "    e.g. dump_YYMMDD_HHMM_SOMETHING_messages, where the ending"
  echo -e "    --without extension-- _messages is hard-wired, for now."
  echo -e ""
  echo -e "    In particular, for now, the ending is '.pcap' and '_messages'"
  echo -e "    for the one and the other file, respectively, hard wired."
  echo -e ""
  echo -e "    Only ASCII alphanumericals are allowed for \"SOMETHING\"."
  echo -e ""
  echo -e "    The syslog excerpt must be modified with the script"
  echo -e "    hhmmss2sec also part of uncenz"
  echo -e "    (not sure if I can quickly modify this script uncenz-syslog-pcap.sh"
  echo -e "    to call hhmmss2sec so you can use just simply a non-modified syslog"
  echo -e "    excerpt)"
  echo -e ""
  echo -e "    THIS IS A DRAFT, DON'T KNOW YET HOW RELIABLY IT WORKS"
  echo -e "    NOR IF IT HAS ANY POTENTIAL TO BE A USEFUL SCRIPT SOME DAY"
  echo -e ""
} 

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

function ask() # borrowed from Advanced Bash Scripting Guide, by Mendel Cooper
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|y*) return 0 ;;
        *) return 1 ;;
    esac
}

PCAP=$(echo $1|sed 's/\.pcap//')
echo \$PCAP: $PCAP
read FAKE

# There's superfluous work right here below, but no time to clean the procedure
tshark -r ${PCAP}.pcap -V -Y 'frame.number' \
	| grep -E 'Frame Number|Arrival Time' | tr '\012' ' ' \
	| sed 's/Frame Number: \([0-9]\{1,6\}\)/Frame Number: \1\n/g'
read FAKE
tshark -r ${PCAP}.pcap -V -Y 'frame.number' \
	| grep -E 'Frame Number|Arrival Time' | tr '\012' ' ' \
	| sed 's/Frame Number: \([0-9]\{1,6\}\)/Frame Number: \1\n/g' \
	| sed 's/Arrival Time: Mar 11, 2017 \(.*\)\..* CET/\1/' | \
	sed "s/.*\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\).*Frame Number: \([0-9]\{1,6\}\)/\1 \2/" \
	> time-frame_number.ls-1
cat time-frame_number.ls-1 | awk '{ print $1 }' > time_by_frno.ls-1
echo "cat time_by_frno.ls-1"
read FAKE
cat time_by_frno.ls-1
read FAKE
arrayTimesByFrNo=($(cat time_by_frno.ls-1));
echo "ls -l \${arrayTimesByFrNo[@]}:"
read FAKE
echo ${arrayTimesByFrNo[@]}
read FAKE
numPackets=${#arrayTimesByFrNo[@]}
echo \$numPackets: $numPackets

echo "we'll be counting from 0 to ($numPackets -1),"
echo "    altogether $numPackets packets"
read FAKE

# we need a file to store the grep'd out lines into, from the syslog, as well
# as output from tshark line on the corresponding frame.number
dumpWSlog=${PCAP}_withSyslog
if [ -e $dumpWSlog ]; then
	mv -iv $dumpWSlog ${dumpWSlog}_$(date +%s)
	> $dumpWSlog
else
	> $dumpWSlog
fi
echo \$dumpWSlog: $dumpWSlog
echo ls -l \$dumpWSlog
ls -l $dumpWSlog
read FAKE

# At start we back up the file. Lots of manipulations follow.
sha256sum ${PCAP}_messages.O ${PCAP}_messages
ls -l ${PCAP}_messages.O ${PCAP}_messages
if [ ! -e  "${PCAP}_messages.O" ]; then
	echo cp -av ${PCAP}_messages ${PCAP}_messages.O
	cp -iav ${PCAP}_messages ${PCAP}_messages.O
else
	if diff ${PCAP}_messages.O ${PCAP}_messages &>/dev/null ; then 
		echo "${PCAP}_messages.O and ${PCAP}_messages are identical"
	else
		echo "${PCAP}_messages.O and ${PCAP}_messages differ"
		echo cp -av ${PCAP}_messages.O ${PCAP}_messages
		cp -av ${PCAP}_messages.O ${PCAP}_messages
		echo "${PCAP}_messages.O and ${PCAP}_messages are now identical"
	fi
fi
sha256sum ${PCAP}_messages.O ${PCAP}_messages
ls -l ${PCAP}_messages.O ${PCAP}_messages

# we'll be working by grep'ing the value of the array
# ${arrayTimesByFrNo[$pkt_number]} (see below) on file
# ${PCAP}_messages, and since the values are all of time in
# consecutive order in fromat hh:mm:ss, just like the values of the array
# ${arrayTimesByFrNo[$pkt_number]}, we can detract the lines that we grep'd
# and printed into results, with head and tail manipulation. for that we need
# the starting $lineNumberSyslog value.
# The value of $lineNumberSyslog will need to be recalculated at every
# traversal of the for loop below.
lineNumberSyslog=$(cat ${PCAP}_messages|wc -l)
echo "\$lineNumberSyslog: $lineNumberSyslog"
read FAKE

echo >> $dumpWSlog; echo SEPARATOR_START_OUTSIDE_OF_LOOP >> $dumpWSlog; echo >> $dumpWSlog
# $pkt_number != $frame_number
for pkt_number in $( seq 0 $(($numPackets -1)) ) ; do
	echo $pkt_number of $numPackets
	echo -n "\${arrayTimesByFrNo[$pkt_number]}: "
	echo ${arrayTimesByFrNo[$pkt_number]}
	read FAKE
	# Now we need to separate the $dumpWSlog_raw into
	# older time line(s), and the grep'd for time line(s). First place the
	# older in $dumpWSlog, then tshark non-verbose on the
	# frame.number, then line(s) with the grep'd for time, and then tshark
	# verbose on the frame.number, all with appropriate separators, so HTML can
	# be easily made by converting those separators properly.
	# On top of all the above, the numbers of lines cut from the syslog need to
	# counted separately (so the separators don't mess with what is detracted).
	echo >> $dumpWSlog; echo SEPARATOR_START_OF_TRAVERSAL >> $dumpWSlog; echo >> $dumpWSlog
	echo >> $dumpWSlog; echo SEPARATOR_START_SYSLOG >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	> count_of_lines
	> count_of_lines_reckoning
	lineNumberSyslog=$(cat ${PCAP}_messages|wc -l)
	echo "\$lineNumberSyslog: $lineNumberSyslog"
	read FAKE
	grep -B1000 ${arrayTimesByFrNo[$pkt_number]} ${PCAP}_messages \
		| grep -v ${arrayTimesByFrNo[$pkt_number]} >> $dumpWSlog
	read FAKE
	grep -B1000 ${arrayTimesByFrNo[$pkt_number]} ${PCAP}_messages \
		| grep -v ${arrayTimesByFrNo[$pkt_number]} | wc -l >> count_of_lines
	echo
	echo cat count_of_lines
	cat count_of_lines
	read FAKE
	echo >> $dumpWSlog; echo SEPARATOR_END_SYSLOG >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	echo \$pkt_number: $pkt_number
	frame_number=$(echo $pkt_number + 1|bc)
	echo \$frame_number: $frame_number
	echo >> $dumpWSlog; echo SEPARATOR_START_TSHARK_NON-VERBOSE >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	echo tshark -r ${PCAP}.pcap -Y frame.number==$frame_number
	tshark -r ${PCAP}.pcap -Y frame.number==$frame_number >> $dumpWSlog
	echo >> $dumpWSlog; echo SEPARATOR_END_TSHARK_NON-VERBOSE >> $dumpWSlog; echo >> $dumpWSlog
	echo >> $dumpWSlog; echo SEPARATOR_START_SYSLOG >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	grep ${arrayTimesByFrNo[$pkt_number]} ${PCAP}_messages \
		>> $dumpWSlog
	grep ${arrayTimesByFrNo[$pkt_number]} ${PCAP}_messages | wc -l >> count_of_lines
	echo Half of loop traversal, part of $dumpWSlog possibly created.
	cat count_of_lines
	read FAKE
	echo >> $dumpWSlog; echo SEPARATOR_END_SYSLOG >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	# In (my) syslog (old syslog-ng) often many consecutive lines hold
	# identical timestamp. The next loop from the start is with the different
	# than previous $pkt_number++.
	echo "\$lineNumberSyslog: $lineNumberSyslog"
	read FAKE
	#echo -n "exec echo " >> count_of_lines_reckoning
	cat count_of_lines | tr '\012' ' ' | sed 's/\([0-9]\) \([0-9]\)/\1 + \2/g' >> count_of_lines_reckoning
	#echo -n '|bc' >> count_of_lines_reckoning
	echo cat count_of_lines_reckoning
	cat count_of_lines_reckoning ; echo
	read FAKE
	linesCounting=$(cat count_of_lines_reckoning)
	echo \$linesCounting: $linesCounting
	linesCount=$(echo $linesCounting|bc)
	echo \$linesCount: $linesCount
	read FAKE
	if grep ${arrayTimesByFrNo[$pkt_number]} ${PCAP}_messages ; then
		tails_to_remain=$(echo $lineNumberSyslog - $linesCount|bc)
		echo "\$tails_to_remain: $tails_to_remain"
		read FAKE
		# I'm aware that there must be one second lapsed btwn successive ${ts}
		# timestamps created, else same name. For now I do that with "read
		# FAKE" and following the script working. But also, overwriting is an
		# option, adds a few seconds.
		ts=$(date +%s) # ts is for timestamp
		ls -l ${PCAP}_messages ${PCAP}_messages_${ts}
		cp -av ${PCAP}_messages \
			${PCAP}_messages_${ts}
		read FAKE
		cat ${PCAP}_messages_${ts} | \
			tail -$tails_to_remain > ${PCAP}_messages
		ls -l ${PCAP}_messages_${ts} ${PCAP}_messages
		read FAKE
	fi

	echo >> $dumpWSlog; echo SEPARATOR_START_TSHARK_VERBOSE >> $dumpWSlog; echo >> $dumpWSlog
	read FAKE
	echo tshark -r ${PCAP}.pcap -V -Y frame.number==$frame_number
	tshark -r ${PCAP}.pcap -V -Y frame.number==$frame_number >> $dumpWSlog
	echo >> $dumpWSlog; echo SEPARATOR_END_TSHARK_VERBOSE >> $dumpWSlog; echo >> $dumpWSlog
	set $pkt_number++
	echo >> $dumpWSlog; echo SEPARATOR_END_OF_TRAVERSAL >> $dumpWSlog; echo >> $dumpWSlog
	echo Another complete loop traversal, part of $dumpWSlog possibly created.
	read FAKE
done
echo >> $dumpWSlog; echo SEPARATOR_END_OUTSIDE_OF_LOOP >> $dumpWSlog; echo >> $dumpWSlog
