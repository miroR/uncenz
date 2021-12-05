#!/bin/bash
#
# uncenz-inter-kill.sh -- pls. see uncenz-inter.sh
# 
# this script is part of the uncenz set of scripts:
# https://github.com/miroR/uncenz
#
# Copyright (C) 2015,2020 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
#

. /home/$USER/.uncenz.conf

echo ". uncenz-setup from ${0##/}"
. uncenz-setup

pidof_g_s=$(<$uncenz_run/uncenz-inter-g-s.pid)
pidof_g_n=$(<$uncenz_run/uncenz-inter-g-n.pid)
echo \$pidof_g_s: $pidof_g_s
echo \$pidof_g_n: $pidof_g_n
pidof_g_s_veri=$( ps aux | grep $pidof_g_s | grep -v grep )
pidof_g_n_veri=$( ps aux | grep $pidof_g_n | grep -v grep )
echo \$pidof_g_s_veri: $pidof_g_s_veri
echo \$pidof_g_n_veri: $pidof_g_n_veri
######################################
#     
# Entire if for uncenz-inter.sh
#         capturing
# uncenz-inter.sh is called by "uncenz-kill"
#      And herewith is killed by being called from
# "uncenz-1st" or, after disabling with INTERIM=n in
# ~HOME/.uncenz.conf, with uncenz-inter-kill.sh.
#     
######################################
read NOP
if [ "X${pidof_g_s_veri}" != "X" ] && [ "X${pidof_g_n_veri}" != "X" ]; then
    ps aux | grep $pidof_g_s
    ps aux | grep $pidof_g_n
    echo
    echo "Hitting Enter here will kill the above, so:"
    echo
    echo "WANRING: do not pause after you hit Enter,"
    echo "if you're online, as nothing will be being captured."
    if [ ! -e "$uncenz_run/uncenz-dump_i" ]; then
        echo "Fix this section of the script. but for now"
        echo "type in the interim PCAP filename (without .pcap):"
        read PCAP
    else
        PCAP=$(<$uncenz_run/uncenz-dump_i)
    fi
    echo \$PCAP: $PCAP
    for uncenz_r_log in .uncenz-r_log_dt .uncenz-r_log_dt_d .uncenz-r_log_vd \
        .uncenz-r_log_vt .uncenz-r_log_tb .uncenz-r_log_tb_d; do
        mark_log=$(echo $uncenz_r_log|sed 's/.uncenz-r_log_\(.*\)/\1/')
        if [ ! -e "${uncenz_r_log}" ]; then
            echo "${uncenz_r_log} non extant. We continue"
            continue
        fi
        echo \$uncenz_r_log: $uncenz_r_log
        r_log=$(<${uncenz_r_log})
        echo \$r_log: $r_log
        if [ -n "$r_log" ]; then
            echo "sudo -s ls -l $r_log"
            sudo -s ls -l $r_log
        else
            echo problems with $r_log
            read NOP_permanent
        fi
        if [ -e "${uncenz_r_log}_strt0_i" ]; then
            # debug
            ls -l ${uncenz_r_log}_strt0_i
            strt0=$(<${uncenz_r_log}_strt0_i)
            echo \$strt0: $strt0
            sudo -s ls -l $r_log
            echo "(ls -l $r_log)"
            read NOP
            echo "sudo -s cat $r_log | grep -a -A300000 \"$strt0\" $r_log > ${PCAP}_r_${mark_log}"
            sudo -s cat $r_log | grep -a -A300000 "$strt0" > /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
            sudo -s chmod 600 /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
            ls -l /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
            if [ ! -s "/home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}" ]; then
                echo "(ls -l /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log})"
                echo "Can you pls. fix that now?"
                read NOP_permanent
            fi
        else
            # If all is as expected here we end only with dt_d and tb_d. Check if so.
            echo $uncenz_r_log | grep 'dt_d\|tb_d'
            read NOP
            if ( echo $uncenz_r_log | grep 'dt_d\|tb_d' ); then
                size_r_log=$(sudo -s ls -l $r_log | awk '{ print $5 }')
                echo \$size_r_log: $size_r_log
                sudo -s cp -iv $r_log /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
                sudo -s chmod 600 /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
                while [ ! -s "/home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}" ]; do
                    sudo -s ls -l  $r_log /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
                    sleep 1
                done
                size_uncenz_r_log=$(ls -l /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log} | awk '{ print $5 }')
                if [ "$size_uncenz_r_log" -ge "$size_r_log" ]; then
                    echo "X        XXXXXXXXXXXXXXXXXXXXX        X"
                    echo "         -=-==-=== ~ ===-==-=-"
                    sudo -s ls -l $r_log /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
                    # temporarily:
                    read NOP_permanent
                    # maybe replace with
                    #sleep 0.4
                    echo "         -=-==-=== ~ ===-==-=-"
                    echo "X        XXXXXXXXXXXXXXXXXXXXX        X"
                else
                    echo "!        !!!!!!!!!!!!!!!!!!!!!        !"
                    echo "!          ERROR, pls. check!        !"
                    echo "         -=-==-=== ~ ===-==-=-"
                    sudo -s ls -l $r_log /home/$USER/.uncenz-1st/${PCAP}_r_${mark_log}
                    read NOP_permanent
                    echo "!          ERROR, pls. check!        !"
                    echo "         -=-==-=== ~ ===-==-=-"
                    echo "!        !!!!!!!!!!!!!!!!!!!!!        !"
                fi
            else
                #sudo -s uncenz-r_trunc $r_log
                echo "Check your script:"
                echo "You shouldn't have ended here."
                read NOP
            fi
        fi
    done
    read NOP
    sudo -s kill $pidof_g_s $pidof_g_n
    echo ps aux | grep $pidof_g_s
    ps aux | grep $pidof_g_s
    echo ps aux | grep $pidof_g_n
    ps aux | grep $pidof_g_n
else
    echo "No interim capturing, nothing to kill."
    read NOP
fi
