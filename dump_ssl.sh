#!/bin/bash
#
# this script is part of uncenz set of scripts
#
# dump_ssl.sh        based on having saved the last line from
#                    $SSLKEYLOGFILE previous to capturing new PCAP in $ssllast_dir dir
#                    with my uncenz-1st script or uncenz-only-dump.sh
#                    (
#                    which is a primitive, imperfect, even marginally *unsafe*
#                    method, actually could be worse than marginally in a poorly
#                    maintained system --but so is maintaining an $SSLKEYLOGFILE
#                    itself on such a system--, I'm not claiming it's a great
#                    method at all, will improve it once I truly dive into
#                    network RFCs and the math of SSL --if ever--
#                    ),
#                    this script will apportion each PCAP of a consecutively
#                    captured PCAPS, placed in current dir, it's own SSL secrets
#                    list from $SSLKEYLOGFILE.
#
#                    All PCAPs start with the string "dump_" and have
#                    extension ".pcap" be they are PCAPNGs or old PCAPs
#
#                    *nix only (I guess), no spaces in filenames, of course
#
#                    run this in its own purpose set up/created dir
#
# Copyright (C) 2015 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
#
function ask()    # this function borrowed from "Advanced BASH Scripting Guide"
                # (a free book) by Mendel Cooper
{
    echo -n "$@" '[y/[n]] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

> prev
# 'prev' for selected in the previous loop
# 'cur' for selected in the current loop
echo "Give the dir where the PCAPs SSLLAST lines are archived:"
read ssllast_dir
if [ ! -d "$ssllast_dir" ]; then
    echo "What you gave ($ssllast_dir) is not a dir."
    exit 1
fi


if [ $# -eq 0 ]; then
    echo "give (a list of) PCAP(s)"
    echo "(if globbing, you need to quote it, e.g.:"
    echo "${0##*/} \"*.pcap\")"
    exit 0
fi

PCAPs=$1
PCAPs_tr=$(ls -1 $1 | tr '\012' ' ')
echo "ls -1 $PCAPs|sed 's/\.pcap//'"
ls -1 $PCAPs|sed 's/\.pcap//'
echo

> .pcaps-no-split-no-interim
for i in $(ls -1 $PCAPs|sed 's/\.pcap//'); do
    if ( echo $i | grep '\-[0-9][0-9]_' ) ||  ( echo $i | grep '_i$' ); then
        echo "Not echoing either the split PCAP or the interim PCAP to the list:"
        ls -l $i.pcap
    else
        echo $i.pcap >> .pcaps-no-split-no-interim
    fi
done
cat .pcaps-no-split-no-interim
echo "(cat .pcaps-no-split-no-interim)"
ls -l .pcaps-no-split-no-interim
read FAKE
PCAPs=$(<.pcaps-no-split-no-interim)
    
for i in $(echo $PCAPs|sed 's/\.pcap//'); do
    echo \$i: $i
done
read FAKE



for cur_raw in $PCAPs ; do
    cur=$(ls -1 $cur_raw|sed 's/dump_//'|sed 's/\.pcap//')
    echo \$cur: $cur
    read FAKE
    prev=""
    if [ -e "prev" ]; then
        prev=$(<prev); echo \$prev: $prev
        read FAKE
    fi
    if [ -e "dump_${prev}.pcap" ]; then
        ls -l $ssllast_dir/SSLLAST_${prev}.txt
        cur_s=""
        prev_s=""
        prev_s=$(<$ssllast_dir/SSLLAST_${prev}.txt)
        echo "\$prev_s: " $prev_s;
        read FAKE
        cur_s=$(<$ssllast_dir/SSLLAST_${cur}.txt)
        echo "\$cur_s: " $cur_s;
        read FAKE
        ls -l $ssllast_dir/SSLLAST_${prev}.txt
        ls -l dump_${prev}.pcap
        echo grep \"$prev_s\" $SSLKEYLOGFILE \| head -3
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
        touch dump_${prev}_SSLKEYLOGFILE.txt -r dump_${prev}.pcap 
        ls -l dump_${prev}_SSLKEYLOGFILE.txt
    else
        ls -l dump_${prev}.pcap
        echo "(non extant)"
    fi
    echo $cur > prev ; echo cat prev ; cat prev
    read FAKE
done
# This ought to be the last (if the previous loop ran):
echo \$cur: $cur
read FAKE
cur_tail_1=$(ls -1 dump*.pcap|tail -1|sed 's/dump_//'|sed 's/\.pcap//')
if [ "$cur" == "$cur_tail_1" ]; then
    cur_s=$(cat $ssllast_dir/SSLLAST_${cur}.txt)
    cat $SSLKEYLOGFILE | grep -A30000 "$cur_s" | grep -v "$cur_s" \
        | wc -l
    cat $SSLKEYLOGFILE | grep -A30000 "$cur_s" | grep -v "$cur_s" \
        > dump_${prev}_SSLKEYLOGFILE.txt
    touch dump_${cur}_SSLKEYLOGFILE.txt -r dump_${cur}.pcap 
    ls -l dump_${cur}_SSLKEYLOGFILE.txt
fi
echo "sleeping 3 sec"
sleep 3
#echo "Do you want me to remove empty *SSLKEYLOGFILE.txt's?"
# If I watch it all going well, and just keep hitting Enter to move faster, I
# go past this point without giving it a "y"... Sleeping a little will
# hopefully correct it. Script still too fresh for me to remove all the read
# FAKE's.
#ask
#if [ "$?" == 0 ]; then
for sslkeylogfile in $(ls -1 *SSLKEYLOGFILE.txt); do
    if [ ! -s "$sslkeylogfile" ]; then
        ls -l $sslkeylogfile
        rm -v $sslkeylogfile
    fi
done
#fi
if [ -e "prev" ]; then rm -f prev ; fi
