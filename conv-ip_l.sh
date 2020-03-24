#!/bin/bash
#
# conv-ip_l.sh		optimizing the useful part of ${PCAP}_tHostsConv.log
#					 	produced by tshark-hosts-conv.sh

PCAP_FILE=$1
num_dots=$(echo $PCAP_FILE|sed 's/\./\n/g'| wc -l)
num_dots_min_1=$(echo $num_dots - 1 | bc)
ext=$(echo $PCAP_FILE|cut -d. -f $num_dots)
dump=$(echo $PCAP_FILE|sed "s/\(.*\)\.$ext/\1/")

grep -A3000 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | grep -B30000 -m2 '=-=-=-=-=-=' > conv-ip_l_raw
echo cat conv-ip_l_raw
cat conv-ip_l_raw
echo "(cat conv-ip_l_raw)"
#read FAKE
# grep for \\x09 no output
cat conv-ip_l_raw | sed 's/\x09/    /g' > conv-ip_l_no_tab
echo cat conv-ip_l_no_tab
cat conv-ip_l_no_tab
echo "(cat conv-ip_l_no_tab)"
#read FAKE
cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->'
#read FAKE
cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->'
#read FAKE
# must be same number of lines
wc_l_ip=$(cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->'|wc -l)
wc_l_traffic=$(cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->'|wc -l)
echo \$wc_l_ip: $wc_l_ip; echo \$wc_l_traffic: $wc_l_traffic
if [ "$wc_l_ip" != "$wc_l_traffic" ]; then
	echo "This would produce no meaningful results, the ip's and host's"
	echo "would not align with the traffic."
	echo "sleep 3, then exiting..."
	exit 1
fi

# Before the two while's further below that will correctly align the
# ip_host_ln's we need to get the ip's and host's themselvs to print properly
# aligned.
# "i" for ip(s) "h" for host(s)
cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->' > hosts-conv-i-h
awk '{ print $1 }' hosts-conv-i-h > hosts-conv-i
awk '{ print $2 }' hosts-conv-i-h > hosts-conv-h
ls -l  hosts-conv-i  hosts-conv-h
##read FAKE
# Find out which the longest string, for both hosts-conv-i  hosts-conv-h
hosts_conv_i_l_max=""
for ip in $(<hosts-conv-i); do
	echo \$ip: $ip
	echo ${#ip}
	hosts_conv_i_l=$(echo ${#ip})
	echo \$hosts_conv_i_l: $hosts_conv_i_l
	##read FAKE
	if [ "X${hosts_conv_i_l_max}" == "X" ]; then 
		hosts_conv_i_l_max=$hosts_conv_i_l
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		##read FAKE
	fi
	echo \$hosts_conv_i_l: $hosts_conv_i_l
	echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		##read FAKE
	if [ "$hosts_conv_i_l" -le "$hosts_conv_i_l_max" ]; then
		echo no change
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
	else
		hosts_conv_i_l_max=$hosts_conv_i_l
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		##read FAKE
	fi
done

hosts_conv_h_l_max=""
for hst in $(<hosts-conv-h); do
	echo \$hst: $hst
	echo ${#hst}
	hosts_conv_h_l=$(echo ${#hst})
	echo \$hosts_conv_h_l: $hosts_conv_h_l
	##read FAKE
	if [ "X${hosts_conv_h_l_max}" == "X" ]; then 
		hosts_conv_h_l_max=$hosts_conv_h_l
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		##read FAKE
	fi
	echo \$hosts_conv_h_l: $hosts_conv_h_l
	echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		##read FAKE
	if [ "$hosts_conv_h_l" -le "$hosts_conv_h_l_max" ]; then
		echo no change
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
	else
		hosts_conv_h_l_max=$hosts_conv_h_l
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		##read FAKE
	fi
done

echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
#echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
##read FAKE
cat hosts-conv-i
##read FAKE
cat hosts-conv-h
##read FAKE
# We need to get the ip-hosts part to print properly. It's been prepared with
# the two for loops above. Now:
hosts_conv_i_ln=1
> hosts-conv-i-try
hosts_conv_i_l_max_p=$(echo $hosts_conv_i_l_max+1|bc)
while [ "$hosts_conv_i_ln" -le "$wc_l_ip" ]; do
	cat hosts-conv-i | head -$hosts_conv_i_ln | tail -1
	cat hosts-conv-i | head -$hosts_conv_i_ln | tail -1 > hosts-conv-i-ln
	echo cat hosts-conv-i-ln
	cat hosts-conv-i-ln
	echo "(cat hosts-conv-i-ln)"
	ls -l hosts-conv-i-ln
	##read FAKE
	hosts_conv_tw=$(cat hosts-conv-i | head -$hosts_conv_i_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_i_ln: $hosts_conv_i_ln
	##read FAKE
	echo \$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p
	##read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_i_l_max_p" ]; then
		#hosts_conv_tw_miss=$(echo $hosts_conv_tw_max-$hosts_conv_tw|bc)
		#echo \$hosts_conv_tw_miss: $hosts_conv_tw_miss
		while [ "$hosts_conv_tw" -le "$hosts_conv_i_l_max_p" ]; do
			cat hosts-conv-i-ln | sed 's/\(.*\)/\1\x20/' > hosts-conv-i-ln_align
			##read FAKE
			hosts_conv_tw=$(cat hosts-conv-i-ln_align | wc -c)
			mv -v hosts-conv-i-ln_align hosts-conv-i-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p)"
		cat hosts-conv-i-ln >> hosts-conv-i-try
	else
		cat hosts-conv-i-ln | sed 's/\(.*\)/\1\x20/' > hosts-conv-i-ln_align
		mv -v hosts-conv-i-ln_align hosts-conv-i-ln
		cat hosts-conv-i-ln >> hosts-conv-i-try
		##read FAKE
	fi
	let hosts_conv_i_ln+=1
done

hosts_conv_h_ln=1
> hosts-conv-h-try
hosts_conv_h_l_max_p=$(echo $hosts_conv_h_l_max+1|bc)
while [ "$hosts_conv_h_ln" -le "$wc_l_ip" ]; do
	cat hosts-conv-h | head -$hosts_conv_h_ln | tail -1
	cat hosts-conv-h | head -$hosts_conv_h_ln | tail -1 > hosts-conv-h-ln
	echo cat hosts-conv-h-ln
	cat hosts-conv-h-ln
	echo "(cat hosts-conv-h-ln)"
	ls -l hosts-conv-h-ln
	##read FAKE
	hosts_conv_tw=$(cat hosts-conv-h | head -$hosts_conv_h_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_h_ln: $hosts_conv_h_ln
	##read FAKE
	echo \$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p
	##read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_h_l_max_p" ]; then
		#hosts_conv_tw_miss=$(echo $hosts_conv_tw_max-$hosts_conv_tw|bc)
		#echo \$hosts_conv_tw_miss: $hosts_conv_tw_miss
		while [ "$hosts_conv_tw" -le "$hosts_conv_h_l_max_p" ]; do
			cat hosts-conv-h-ln | sed 's/\(.*\)/\1\x20/' > hosts-conv-h-ln_align
			##read FAKE
			hosts_conv_tw=$(cat hosts-conv-h-ln_align | wc -c)
			mv -v hosts-conv-h-ln_align hosts-conv-h-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p)"
		cat hosts-conv-h-ln >> hosts-conv-h-try
	else
		cat hosts-conv-h-ln | sed 's/\(.*\)/\1\x20/' > hosts-conv-h-ln_align
		mv -v hosts-conv-h-ln_align hosts-conv-h-ln
		cat hosts-conv-h-ln >> hosts-conv-h-try
		##read FAKE
	fi
	let hosts_conv_h_ln+=1
done

# well printed now:
paste hosts-conv-i-try hosts-conv-h-try | sed 's/\t//' > hosts-conv-i-h-try
##read FAKE

# The right side, the traffic.
cat conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->' > hosts-conv-traffic
paste hosts-conv-i-h-try hosts-conv-traffic | sed 's/\t//' > hosts-conv-all
# That's the body of it.

# Now the header.
hosts_conv_head_1_l=$(grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -2 | head -1 | wc -c) 
hosts_conv_head_2_l=$(grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -1 | head -1 | wc -c) 
# Muss be same:
if [ "$hosts_conv_head_1_l" != "$hosts_conv_head_2_l" ]; then
	echo "Probably minor inconvenience. Not exiting with failure, but..."
	echo "...Just pls. mark my words:"
	echo "NOT completely correct ouutput."
	#read FAKE_perm
fi

grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -2 > hosts-conv-head
hosts_conv_all_l=$(head -1 hosts-conv-all | wc -c)
echo \$hosts_conv_all_l: $hosts_conv_all_l
#read FAKE
hosts_conv_head_ln=1
> hosts-conv-head-try
while [ "$hosts_conv_head_ln" -le "2" ]; do
	cat hosts-conv-head | head -$hosts_conv_head_ln | tail -1
	cat hosts-conv-head | head -$hosts_conv_head_ln | tail -1 > hosts-conv-head-ln
	echo cat hosts-conv-head-ln
	cat hosts-conv-head-ln
	echo "(cat hosts-conv-head-ln)"
	ls -l hosts-conv-head-ln
	#read FAKE
	hosts_conv_tw=$(cat hosts-conv-head | head -$hosts_conv_head_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_head_ln: $hosts_conv_head_ln
	#read FAKE
	echo \$hosts_conv_all_l: $hosts_conv_all_l
	#read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_all_l" ]; then
		while [ "$hosts_conv_tw" -le "$hosts_conv_all_l" ]; do
			cat hosts-conv-head-ln | sed 's/\(.*\)/\x20\1/' > hosts-conv-head-ln_align
			#read FAKE
			hosts_conv_tw=$(cat hosts-conv-head-ln_align | wc -c)
			mv -v hosts-conv-head-ln_align hosts-conv-head-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_all_l: $hosts_conv_all_l)"
		cat hosts-conv-head-ln >> hosts-conv-head-try
	else
		cat hosts-conv-head-ln | sed 's/\(.*\)/\x20\1/' > hosts-conv-head-ln_align
		mv -v hosts-conv-head-ln_align hosts-conv-head-ln
		cat hosts-conv-head-ln >> hosts-conv-head-try
		#read FAKE
	fi
cat hosts-conv-head-try hosts-conv-all > ${dump}_conv-ip_l.txt
	let hosts_conv_head_ln+=1
done
# This one-instance-only-in-same-dir _appears_ to work. But this script is part of
# uncenz-2nd -called scripts, and must be multiple-instances-in-same-dir
# viable.
ls -l ${dump}_conv-ip_l.txt
# The temps need to be removed too... Committing this script to uncenz git first.
