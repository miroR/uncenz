#!/bin/bash
#
# conv-ip_l.sh		optimizing the useful part of ${PCAP}_tHostsConv.log
#					 	produced by tshark-hosts-conv.sh

PCAP_FILE=$1
num_dots=$(echo $PCAP_FILE|sed 's/\./\n/g'| wc -l)
num_dots_min_1=$(echo $num_dots - 1 | bc)
ext=$(echo $PCAP_FILE|cut -d. -f $num_dots)
dump=$(echo $PCAP_FILE|sed "s/\(.*\)\.$ext/\1/")

# This script is in the set of {uncenz-2nd}-called scripts, and is now
# multiple-instances-in-same-dir viable:
touch ${dump}_conv-ip_l.txt
# There remain temps to be removed...

grep -A3000 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | grep -B30000 -m2 '=-=-=-=-=-=' > ${dump}_conv-ip_l_raw
echo cat ${dump}_conv-ip_l_raw
cat ${dump}_conv-ip_l_raw
echo "(cat ${dump}_conv-ip_l_raw)"
#read FAKE
# grep for \\x09 no output
cat ${dump}_conv-ip_l_raw | sed 's/\x09/    /g' > ${dump}_conv-ip_l_no_tab
echo cat ${dump}_conv-ip_l_no_tab
cat ${dump}_conv-ip_l_no_tab
echo "(cat ${dump}_conv-ip_l_no_tab)"
#read FAKE
cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->'
#read FAKE
cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->'
#read FAKE
# must be same number of lines
wc_l_ip=$(cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->'|wc -l)
wc_l_traffic=$(cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->'|wc -l)
echo \$wc_l_ip: $wc_l_ip; echo \$wc_l_traffic: $wc_l_traffic
if [ "$wc_l_ip" != "$wc_l_traffic" ]; then
	echo "This would produce no meaningful results, the ip's and host's"
	echo "would not align with the traffic."
	echo "sleep 3, then exiting..."
	sleep 3
	exit 1
fi

# Before the two while's further below that will correctly align the
# ip_host_ln's we need to get the ip's and host's themselvs to print properly
# aligned.
# "i" for ip(s) "h" for host(s)
cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep -v '<->' > ${dump}_hosts-i-h
awk '{ print $1 }' ${dump}_hosts-i-h > ${dump}_hosts-i
awk '{ print $2 }' ${dump}_hosts-i-h > ${dump}_hosts-h
ls -l  ${dump}_hosts-i  ${dump}_hosts-h
#read FAKE
# Find out which the longest string, for both ${dump}_hosts-i  ${dump}_hosts-h
hosts_conv_i_l_max=""
for ip in $(<${dump}_hosts-i); do
	echo \$ip: $ip
	echo ${#ip}
	hosts_conv_i_l=$(echo ${#ip})
	echo \$hosts_conv_i_l: $hosts_conv_i_l
	#read FAKE
	if [ "X${hosts_conv_i_l_max}" == "X" ]; then 
		hosts_conv_i_l_max=$hosts_conv_i_l
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		#read FAKE
	fi
	echo \$hosts_conv_i_l: $hosts_conv_i_l
	echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		#read FAKE
	if [ "$hosts_conv_i_l" -le "$hosts_conv_i_l_max" ]; then
		echo no change
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
	else
		hosts_conv_i_l_max=$hosts_conv_i_l
		echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
		#read FAKE
	fi
done

hosts_conv_h_l_max=""
for hst in $(<${dump}_hosts-h); do
	echo \$hst: $hst
	echo ${#hst}
	hosts_conv_h_l=$(echo ${#hst})
	echo \$hosts_conv_h_l: $hosts_conv_h_l
	#read FAKE
	if [ "X${hosts_conv_h_l_max}" == "X" ]; then 
		hosts_conv_h_l_max=$hosts_conv_h_l
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		#read FAKE
	fi
	echo \$hosts_conv_h_l: $hosts_conv_h_l
	echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		#read FAKE
	if [ "$hosts_conv_h_l" -le "$hosts_conv_h_l_max" ]; then
		echo no change
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
	else
		hosts_conv_h_l_max=$hosts_conv_h_l
		echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
		#read FAKE
	fi
done

echo \$hosts_conv_i_l_max: $hosts_conv_i_l_max
#echo \$hosts_conv_h_l_max: $hosts_conv_h_l_max
#read FAKE
cat ${dump}_hosts-i
#read FAKE
cat ${dump}_hosts-h
#read FAKE
# We need to get the ip-hosts part to print properly. It's been prepared with
# the two for loops above. Now:
hosts_conv_i_ln=1
> ${dump}_hosts-i-try
hosts_conv_i_l_max_p=$(echo $hosts_conv_i_l_max+1|bc)
while [ "$hosts_conv_i_ln" -le "$wc_l_ip" ]; do
	cat ${dump}_hosts-i | head -$hosts_conv_i_ln | tail -1
	cat ${dump}_hosts-i | head -$hosts_conv_i_ln | tail -1 > ${dump}_hosts-i-ln
	echo cat ${dump}_hosts-i-ln
	cat ${dump}_hosts-i-ln
	echo "(cat ${dump}_hosts-i-ln)"
	ls -l ${dump}_hosts-i-ln
	#read FAKE
	hosts_conv_tw=$(cat ${dump}_hosts-i | head -$hosts_conv_i_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_i_ln: $hosts_conv_i_ln
	#read FAKE
	echo \$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p
	#read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_i_l_max_p" ]; then
		while [ "$hosts_conv_tw" -le "$hosts_conv_i_l_max_p" ]; do
			cat ${dump}_hosts-i-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-i-ln_align
			#read FAKE
			hosts_conv_tw=$(cat ${dump}_hosts-i-ln_align | wc -c)
			mv -v ${dump}_hosts-i-ln_align ${dump}_hosts-i-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p)"
		cat ${dump}_hosts-i-ln >> ${dump}_hosts-i-try
	else
		cat ${dump}_hosts-i-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-i-ln_align
		mv -v ${dump}_hosts-i-ln_align ${dump}_hosts-i-ln
		cat ${dump}_hosts-i-ln >> ${dump}_hosts-i-try
		#read FAKE
	fi
	let hosts_conv_i_ln+=1
done

hosts_conv_h_ln=1
> ${dump}_hosts-h-try
hosts_conv_h_l_max_p=$(echo $hosts_conv_h_l_max+1|bc)
while [ "$hosts_conv_h_ln" -le "$wc_l_ip" ]; do
	cat ${dump}_hosts-h | head -$hosts_conv_h_ln | tail -1
	cat ${dump}_hosts-h | head -$hosts_conv_h_ln | tail -1 > ${dump}_hosts-h-ln
	echo cat ${dump}_hosts-h-ln
	cat ${dump}_hosts-h-ln
	echo "(cat ${dump}_hosts-h-ln)"
	ls -l ${dump}_hosts-h-ln
	#read FAKE
	hosts_conv_tw=$(cat ${dump}_hosts-h | head -$hosts_conv_h_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_h_ln: $hosts_conv_h_ln
	#read FAKE
	echo \$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p
	#read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_h_l_max_p" ]; then
		while [ "$hosts_conv_tw" -le "$hosts_conv_h_l_max_p" ]; do
			cat ${dump}_hosts-h-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-h-ln_align
			#read FAKE
			hosts_conv_tw=$(cat ${dump}_hosts-h-ln_align | wc -c)
			mv -v ${dump}_hosts-h-ln_align ${dump}_hosts-h-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p)"
		cat ${dump}_hosts-h-ln >> ${dump}_hosts-h-try
	else
		cat ${dump}_hosts-h-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-h-ln_align
		mv -v ${dump}_hosts-h-ln_align ${dump}_hosts-h-ln
		cat ${dump}_hosts-h-ln >> ${dump}_hosts-h-try
		#read FAKE
	fi
	let hosts_conv_h_ln+=1
done

# well printed now:
paste ${dump}_hosts-i-try ${dump}_hosts-h-try | sed 's/\t//' > ${dump}_hosts-i-h-try
#read FAKE

# The right side, the traffic.
cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->' > ${dump}_hosts-conv-traffic
paste ${dump}_hosts-i-h-try ${dump}_hosts-conv-traffic | sed 's/\t//' > ${dump}_hosts-conv-all
# That's the body of it.

# Now the header.
hosts_conv_head_1_l=$(grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -2 | head -1 | wc -c) 
hosts_conv_head_2_l=$(grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -1 | head -1 | wc -c) 
# Must be same:
if [ "$hosts_conv_head_1_l" != "$hosts_conv_head_2_l" ]; then
	echo "Probably _minor_ inconvenience. Not exiting with failure, but..."
	echo "...Just pls. mark my words:"
	echo "possibly NOT completely correct ouutput:"
	echo "The two lines in the header for conv-ip_l.txt have different length."
	read FAKE_perm
fi

grep -A3 -m1 '=-=-=-=-=-=' ${dump}_tHostsConv.log | tail -2 > ${dump}_hosts-head
hosts_conv_all_l=$(head -1 ${dump}_hosts-conv-all | wc -c)
echo \$hosts_conv_all_l: $hosts_conv_all_l
echo $hosts_conv_all_l > .${dump}_conv-ip_l.tw
# "p" plus, else it's one line missing in bottom with the xterm command, see below
wc_l_ip_p=$(echo $wc_l_ip+3|bc)
echo $wc_l_ip_p > .${dump}_conv-ip_l.th
#read FAKE
hosts_conv_head_ln=1
> ${dump}_hosts-head-try
while [ "$hosts_conv_head_ln" -le "2" ]; do
	cat ${dump}_hosts-head | head -$hosts_conv_head_ln | tail -1
	cat ${dump}_hosts-head | head -$hosts_conv_head_ln | tail -1 > ${dump}_hosts-head-ln
	echo cat ${dump}_hosts-head-ln
	cat ${dump}_hosts-head-ln
	echo "(cat ${dump}_hosts-head-ln)"
	ls -l ${dump}_hosts-head-ln
	#read FAKE
	hosts_conv_tw=$(cat ${dump}_hosts-head | head -$hosts_conv_head_ln | tail -1 | wc -c)
	echo \$hosts_conv_tw: $hosts_conv_tw
	echo \$hosts_conv_head_ln: $hosts_conv_head_ln
	#read FAKE
	echo \$hosts_conv_all_l: $hosts_conv_all_l
	#read FAKE
	if [ "$hosts_conv_tw" -lt "$hosts_conv_all_l" ]; then
		while [ "$hosts_conv_tw" -le "$hosts_conv_all_l" ]; do
			cat ${dump}_hosts-head-ln | sed 's/\(.*\)/\x20\1/' > ${dump}_hosts-head-ln_align
			#read FAKE
			hosts_conv_tw=$(cat ${dump}_hosts-head-ln_align | wc -c)
			mv -v ${dump}_hosts-head-ln_align ${dump}_hosts-head-ln
		done
		echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_all_l: $hosts_conv_all_l)"
		cat ${dump}_hosts-head-ln >> ${dump}_hosts-head-try
	else
		cat ${dump}_hosts-head-ln | sed 's/\(.*\)/\x20\1/' > ${dump}_hosts-head-ln_align
		mv -v ${dump}_hosts-head-ln_align ${dump}_hosts-head-ln
		cat ${dump}_hosts-head-ln >> ${dump}_hosts-head-try
		#read FAKE
	fi
cat ${dump}_hosts-head-try ${dump}_hosts-conv-all > ${dump}_conv-ip_l.txt
	let hosts_conv_head_ln+=1
done
# Removing temps:
for temps in $(echo ${dump}_conv-ip_l_raw ${dump}_conv-ip_l_no_tab \
	${dump}_hosts-i-h ${dump}_hosts-i ${dump}_hosts-h ${dump}_hosts-i-ln \
	${dump}_hosts-i-try ${dump}_hosts-h-ln ${dump}_hosts-h-try \
	${dump}_hosts-i-h-try ${dump}_hosts-conv-traffic ${dump}_hosts-conv-all \
	${dump}_hosts-head ${dump}_hosts-head-ln ${dump}_hosts-head-try); do
	rm -v $temps
done
ls -l ${dump}_conv-ip_l.txt
ls -l .${dump}_conv-ip_l.tw .${dump}_conv-ip_l.th
cat .${dump}_conv-ip_l.tw
echo "(cat .${dump}_conv-ip_l.tw)"
cat .${dump}_conv-ip_l.th
echo "(cat .${dump}_conv-ip_l.th)"
# Not very ingenious, but it can be:
# w=$(<.${dump}_conv-ip_l.tw)
# h=$(<.${dump}_conv-ip_l.th)
# xterm -g ${w}x${h}+50+20 -fn "-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso10646-1" -e "view ${dump}_conv-ip_l.txt"
