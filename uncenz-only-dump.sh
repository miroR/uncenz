#!/bin/bash
#
# uncenz-only-dump.sh                   capture only the network trace
# 
# this script is part the uncenz set of scripts:
# https://github.com/miroR/uncenz
#
# This is a simple standalone script, actually separate from the set, that will
# often be more practical to use: just dumpcamp'ing. Much simpler, but it's
# akin to recording only voice and not picture ;-) . You can't show with
# blatant evidence to non-experts (which is very much needed!) the censorship
# that happened, in cases where stuff like, e.g.  clickjacking and such visual
# events happened.
#
#dupidof=`pidof dumpcap`
dumpcap=dump_$(date +%y%m%d_%H%M)_$(hostname)_SOLO.pcap
ssllast=SSLLAST_$(date +%y%m%d_%H%M)_$(hostname)_SOLO.txt
echo $dumpcap
sudo -s touch $dumpcap
tail -1 $SSLKEYLOGFILE > ~/$ssllast
chmod 600 ~/$ssllast
echo stored ~/$ssllast ...
sudo dumpcap -i any -w $dumpcap &
#echo \$dupid is: # du for dumpcap
# vim: set tabstop=4 expandtab:
