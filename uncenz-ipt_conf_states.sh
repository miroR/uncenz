#!/bin/bash
#
# uncenz-ipt_conf_states.sh -- script to take the conf and state of the network
#
# this is (in broader way) part of my uncenz program at:
# https://github.com/miroR/uncenz
#
# Pls. see the repo for details
#
# If the right lines in uncenz-1st are uncommented, this script is called and
# run

if [ -e ".uncenz-ts" ]; then
	tstamp_hst=$(cat .uncenz-ts)_$(hostname)
else
	tstamp_hst=$(date +%y%m%d_%H%M)_$(hostname)
fi
echo \$tstamp_hst: $tstamp_hst
iptables -t filter -L -n -v > ipt-t_flt-L-n-v_${tstamp_hst}
iptables -t nat -L -n -v > ipt-t_nat-L-n-v_${tstamp_hst}
iptables -t mangle -L -n -v > ipt-t_mgl-L-n-v_${tstamp_hst}
iptables -t raw -L -n -v > ipt-t_raw-L-n-v_${tstamp_hst}
ip link show > ip_link_show_${tstamp_hst}
ip addr show > ip_addr_show_${tstamp_hst}
ip rout show > ip_rout_show_${tstamp_hst}
#cat /etc/resolv.conf
cp -a /etc/resolv.conf resolv_conf_${tstamp_hst}
mkdir ipt_${tstamp_hst}.d/
mv *_${tstamp_hst} ipt_${tstamp_hst}.d/

