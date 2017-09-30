#!/bin/bash
#
# this script is part of uncenz set of scripts
#
# dump_ssl.sh		based on having saved the last line from
#                   $SSLKEYLOGFILE previous to capturing new PCAP in $HOME dir
#                   with my uncenz-1st script or uncenz-only-dump.sh
#					(
#					which is a primitive, imperfect, even marginally *unsafe*
#					method, I'm not claiming it's a great method at all
#					),
#                   this script will apportion each PCAP of a consecutively
#                   captured PCAPS, placed in current dir, it's own SSL secrets
#                   list from $SSLKEYLOGFILE.
#
#					All PCAPs start with the string "dump_" and have
#					extension ".pcap" be they are PCAPNGs or old PCAPs
#
#					*nix only (I guess), no spaces in filenames, of course
#
#					run this in its own purpose set up/created dir
#
# Copyright (C) 2015 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
#
> prev
# 'prev' for selected in the previous loop
# 'cur' for selected in the current loop
for cur in $(ls -1 dump*.pcap|sed 's/dump_//'|sed 's/\.pcap//'); do
	prev=""
	if [ -e "prev" ]; then
		prev=$(cat prev); echo \$prev: $prev
	fi
	if [ -s "$prev" ]; then
		if [ -e "dump_${prev}_SSLKEYLOGFILE.txt" ]; then
			rm -v dump_${prev}_SSLKEYLOGFILE.txt
		else
		ls -l dump_${prev}_SSLKEYLOGFILE.txt
		fi
	fi
	if [ -e "dump_${prev}.pcap" ]; then
		ls -l $HOME/SSLLAST_${prev}.txt
		cur_s=""
		prev_s=""
		prev_s=$(cat $HOME/SSLLAST_${prev}.txt);
		echo "\$prev_s: " $prev_s;
		cur_s=$(cat $HOME/SSLLAST_${cur}.txt);
		echo "\$cur_s: " $cur_s;
		read FAKE
		ls -l $HOME/SSLLAST_${prev}.txt
		ls -l dump_${prev}.pcap
		echo grep \"$prev_s\" $SSLKEYLOGFILE | head -3
		grep "$prev_s" $SSLKEYLOGFILE
		read FAKE
		cat $SSLKEYLOGFILE | grep -A30000 "$prev_s" \
			| head -3
		echo "(head only)"
		read FAKE
		grep "$cur_s" $SSLKEYLOGFILE
		read FAKE
		cat $SSLKEYLOGFILE | grep -A30000 "$prev_s" | grep -v "$prev_s" \
			| grep -B30000 "$cur_s" | tail -3
		echo "(tail only)"
		cat $SSLKEYLOGFILE | grep -A30000 "$prev_s" | grep -v "$prev_s" \
			| grep -B30000 "$cur_s" | wc -l
		read FAKE
		echo \$prev: $prev
		read FAKE
		cat $SSLKEYLOGFILE | grep -A30000 "$prev_s" | grep -v "$prev_s" \
			| grep -B30000 "$cur_s" > dump_${prev}_SSLKEYLOGFILE.txt
		ls -l dump_${prev}_SSLKEYLOGFILE.txt
	fi
	echo $cur > prev ; echo cat prev ; cat prev
	read FAKE
done
