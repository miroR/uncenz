#!/bin/bash
#
# Copyright (C) 2015 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
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
