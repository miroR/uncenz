#!/bin/bash
#
# uncenz-inter.sh   --    capture only the network trace and only some logs
#                         in the interval btwn work-runs. Designed not for
#                         heavy loaded capturing/screencasting but for interim
#                         intervals.
# 
# this script is part of the uncenz set of scripts:
# https://github.com/miroR/uncenz
#
# Copyright (C) 2015,2020 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
#
# if INTERIM=y is set in /home/$USER/.uncenz.conf this script is called by
# uncenz-kill. uncenz-1st kills its $dumper process upon starting. See those
# scripts.
#

. /home/$USER/.uncenz.conf

echo ". uncenz-setup from ${0##/}"
. uncenz-setup

hst=$(hostname|sed 's/\(...\).*/\1/')
# uncenz-1st will need $uncenz_run/uncenz-ts for its session later.
# "-i" because in routine work it does not exist
cp -iav $uncenz_run/uncenz-ts $uncenz_run/uncenz-ts.REAL
uncenz-ts
ts=$(<$uncenz_run/uncenz-ts)
tsh=${ts}_${hst}
the_dump=dump_${tsh}_i.pcap
# Needed for naming the few logs taken:
echo dump_${tsh}_i > $uncenz_run/uncenz-dump_i
read NOP
dumper=$DUMPER
if [ "X${dumper}" == "X" ]; then
    echo \$dumper: $dumper
    echo "Pls. fix this, can't work."
    exit 1
fi
echo $the_dump
if [ "$dumper" == "dumpcap" ]; then
    sudo -s touch $the_dump
fi
if [ "$dumper" == "tcpdump" ]; then
    echo sudo -s touch $the_dump
    sudo -s touch $the_dump
    echo sudo -s chown tcpdump:tcpdump $the_dump
    sudo -s chown tcpdump:tcpdump $the_dump
    read NOP
fi
if [ "$dumper" == "dumpcap" ]; then
    echo "Warning dumpcap not tested for the "-C" option addition"
    read NOP
    sudo -s $dumper -i any -C 100 -w $the_dump &
fi
if [ "$dumper" == "tcpdump" ]; then
    sudo -s $dumper -C 100 -i any -U -f \
		"net not 192.168.88.0 mask 255.255.255.0 \
		and net not 192.168.2.0 mask 255.255.255.0" \
		-w $the_dump -Z tcpdump & pid=$!
    echo $pid > $uncenz_run/uncenz-inter.pid
    # Not enough, I'm afraid:
    ps aux | grep tcpdump | grep -v grep | wc -l
    > $uncenz_run/uncenz-inter-g-s.pid; > $uncenz_run/uncenz-inter-g-n.pid
    ps aux | grep tcpdump | grep -v grep | grep sudo \
        | awk '{ print $2 }' > $uncenz_run/uncenz-inter-g-s.pid
    ps aux | grep tcpdump | grep -v grep | grep -v sudo \
        | awk '{ print $2 }' > $uncenz_run/uncenz-inter-g-n.pid
fi
#sudo -s $dumper -i any -w $the_dump &
mv -v $uncenz_run/uncenz-ts.REAL $uncenz_run/uncenz-ts

pidof_g_s=$(<$uncenz_run/uncenz-inter-g-s.pid)
pidof_g_n=$(<$uncenz_run/uncenz-inter-g-n.pid)
echo \$pidof_g_s: $pidof_g_s
echo \$pidof_g_n: $pidof_g_n
pidof_g_s_veri=$( ps aux | grep $pidof_g_s | grep -v grep )
pidof_g_n_veri=$( ps aux | grep $pidof_g_n | grep -v grep )
echo \$pidof_g_s_veri: $pidof_g_s_veri
echo \$pidof_g_n_veri: $pidof_g_n_veri
read NOP
if [ "X${pidof_g_s_veri}" != "X" ] && [ "X${pidof_g_n_veri}" != "X" ]; then
    ps aux | grep $pidof_g_s
    ps aux | grep $pidof_g_n
    echo
    if [ ! -e "$uncenz_run/uncenz-dump_i" ]; then
        echo "Fix this section of the script. but for now"
        echo "type in the interim PCAP filename (without .pcap):"
        read PCAP
    else
        PCAP=$(<$uncenz_run/uncenz-dump_i)
    fi
    echo \$PCAP: $PCAP
    for uncenz_r_log in $uncenz_run/uncenz-r_log_dt_d \
        $uncenz_run/uncenz-r_log_tb_d; do
        mark_log=$(echo $uncenz_r_log|sed 's/.uncenz-r_log_\(.*\)/\1/')
        mark_log=$(echo $uncenz_r_log|sed 's$\$uncenz_run/uncenz-r_log_\(.*\)$\1$')
        if [ ! -e "${uncenz_r_log}" ]; then
            echo "${uncenz_r_log} non extant. We continue"
            continue
        fi
        echo \$uncenz_r_log: $uncenz_r_log
        read NOP
        r_log=$(<${uncenz_r_log})
        echo \$r_log: $r_log
        if [ -n "$r_log" ]; then
            echo "sudo -s ls -l $r_log"
            sudo -s ls -l $r_log
        else
            echo problems with $r_log
            read NOP_permanent
        fi
        read NOP
        if [ -e "${uncenz_r_log}_strt0_i" ]; then
            echo "Check your script:"
            echo "You shouldn't have ended here."
            read NOP
        else
            # If all is as expected here we end only with dt_d and tb_d. Check if so.
            echo $uncenz_r_log | grep 'dt_d\|tb_d'
            read NOP
            if ( echo $uncenz_r_log | grep 'dt_d\|tb_d' ); then
                sudo -s ls -l $r_log 
                sudo -s uncenz-r_trunc $r_log
            else
                echo "Check your script:"
                echo "You shouldn't have ended here."
                read NOP
            fi
        fi
    done
    echo "No hosts are filtered, all are traced, take notice!"; sleep 0.2
    ls -l $the_dump
    read NOP
    echo "But silently, and NO screen capture."; sleep 0.2
    ls -l $the_dump
    read NOP
    echo "NOTE: this is interim minimal and silent capturing."
    echo "       for no-load non-intensive work"
    echo "You can end it by starting another work-capture with:"
    echo "uncenz-1st"
	echo "or if you disable it with INTERIM=n in ~/home/$USER/uncenz.conf,"
    echo "you need to kill it with:"
	echo "uncenz-inter-kill.sh"
    ls -l $the_dump
    read NOP
fi
# vim: set tabstop=4 expandtab:
