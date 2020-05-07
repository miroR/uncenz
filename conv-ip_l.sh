#!/bin/bash
#
# conv-ip_l.sh        optimizes what tshark-hosts-conv.sh
#                        extracted to ${dump}.conv-ip_l
#

PCAP_FILE=$1
echo \$PCAP_FILE: $PCAP_FILE
ext=${PCAP_FILE##*.}
dump=${PCAP_FILE%*.pcap}
echo \$ext: $ext

# This script is in the set of uncenz-2nd -required/-called scripts, and is
# multiple-instances-in-same-dir viable:
if [ -e ".${dump}_conv-ip_FIX_source" ]; then
    echo "${dump}.pcap can't be worked before you fix it, there is:"
    ls -l .${dump}_conv-ip_FIX_source
    echo "exiting in 5 sec"
    sleep 5
    exit 0
fi
ts=$(date +%s)
if [ -e "${dump}_conv-ip_l.txt" ] && [ ! -s "${dump}_conv-ip_l.txt" ]; then
    rm -v ${dump}_conv-ip_l.txt
fi
if [ -e "${dump}_conv-ip_l.lock" ]; then
	echo "${dump}.pcap likely being worked by another ${0##/} instance"
	ls -l ${dump}_conv-ip_l.lock
	exit 0
fi
touch ${dump}_conv-ip_l.lock
ls -l ${dump}_conv-ip_l.lock
if [ -e "${dump}_conv-ip_l.txt" ]; then
    mv ${dump}_conv-ip_l.txt ${dump}_conv-ip_l.txt_${ts}
fi
if [ -e "${dump}.conv-ip_l" ]; then
    source=${dump}.conv-ip_l
else
    source=${dump}_tHostsConv.log
fi
grep -A3000 -m1 '=-=-=-=-=-=' $source | grep -B30000 -m2 '=-=-=-=-=-=' > ${dump}_conv-ip_l_raw
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
    touch .${dump}_conv-ip_FIX_source
    ls -l .${dump}_conv-ip_FIX_source
    rm -v ${dump}_conv-ip_l.txt
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
    hosts_conv_i_l=${#ip}
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
    fi
    #read FAKE
done

hosts_conv_h_l_max=""
for hst in $(<${dump}_hosts-h); do
    echo \$hst: $hst
    hosts_conv_h_l=${#hst}
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
    fi
    #read FAKE
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
hosts_conv_line=1
> ${dump}_hosts-i-try
let hosts_conv_i_l_max_p=$hosts_conv_i_l_max+1
while [ "$hosts_conv_line" -le "$wc_l_ip" ]; do
    cat ${dump}_hosts-i | head -$hosts_conv_line | tail -1
    cat ${dump}_hosts-i | head -$hosts_conv_line | tail -1 > ${dump}_hosts-i-ln
    echo cat ${dump}_hosts-i-ln
    cat ${dump}_hosts-i-ln
    echo "(cat ${dump}_hosts-i-ln)"
    ls -l ${dump}_hosts-i-ln
    hosts_conv_i_ln=$(<${dump}_hosts-i-ln)
    hosts_conv_tw=${#hosts_conv_i_ln}
    let hosts_conv_tw+=1
    echo \$hosts_conv_tw: $hosts_conv_tw
    echo \$hosts_conv_line: $hosts_conv_line
    echo \$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p
    #read FAKE
    if [ "$hosts_conv_tw" -lt "$hosts_conv_i_l_max_p" ]; then
        while [ "$hosts_conv_tw" -le "$hosts_conv_i_l_max_p" ]; do
            cat ${dump}_hosts-i-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-i-ln_align
            dump_hosts_i_ln_align=$(<${dump}_hosts-i-ln_align)
            hosts_conv_tw=${#dump_hosts_i_ln_align}
            let hosts_conv_tw+=1
            mv -v ${dump}_hosts-i-ln_align ${dump}_hosts-i-ln
        done
        echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_i_l_max_p: $hosts_conv_i_l_max_p)"
        cat ${dump}_hosts-i-ln >> ${dump}_hosts-i-try
    else
        cat ${dump}_hosts-i-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-i-ln_align
        mv -v ${dump}_hosts-i-ln_align ${dump}_hosts-i-ln
        cat ${dump}_hosts-i-ln >> ${dump}_hosts-i-try
    fi
    #read FAKE
    let hosts_conv_line+=1
done

hosts_conv_line=1
> ${dump}_hosts-h-try
let hosts_conv_h_l_max_p=$hosts_conv_h_l_max+1
while [ "$hosts_conv_line" -le "$wc_l_ip" ]; do
    cat ${dump}_hosts-h | head -$hosts_conv_line | tail -1
    cat ${dump}_hosts-h | head -$hosts_conv_line | tail -1 > ${dump}_hosts-h-ln
    echo cat ${dump}_hosts-h-ln
    cat ${dump}_hosts-h-ln
    echo "(cat ${dump}_hosts-h-ln)"
    ls -l ${dump}_hosts-h-ln
    hosts_conv_h_ln=$(<${dump}_hosts-h-ln)
    hosts_conv_tw=${#hosts_conv_h_ln}
    let hosts_conv_tw+=1
    echo \$hosts_conv_tw: $hosts_conv_tw
    echo \$hosts_conv_line: $hosts_conv_line
    echo \$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p
    #read FAKE
    if [ "$hosts_conv_tw" -lt "$hosts_conv_h_l_max_p" ]; then
        while [ "$hosts_conv_tw" -le "$hosts_conv_h_l_max_p" ]; do
            cat ${dump}_hosts-h-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-h-ln_align
            dump_hosts_h_ln_align=$(<${dump}_hosts-h-ln_align)
            hosts_conv_tw=${#dump_hosts_h_ln_align}
            let hosts_conv_tw+=1
            mv -v ${dump}_hosts-h-ln_align ${dump}_hosts-h-ln
        done
        echo "\$hosts_conv_tw: $hosts_conv_tw (\$hosts_conv_h_l_max_p: $hosts_conv_h_l_max_p)"
        cat ${dump}_hosts-h-ln >> ${dump}_hosts-h-try
    else
        cat ${dump}_hosts-h-ln | sed 's/\(.*\)/\1\x20/' > ${dump}_hosts-h-ln_align
        mv -v ${dump}_hosts-h-ln_align ${dump}_hosts-h-ln
        cat ${dump}_hosts-h-ln >> ${dump}_hosts-h-try
    fi
    let hosts_conv_line+=1
    #read FAKE
done

# well printed now:
paste ${dump}_hosts-i-try ${dump}_hosts-h-try | sed 's/\t//' > ${dump}_hosts-i-h-try
#read FAKE

# The right side, the traffic.
cat ${dump}_conv-ip_l_no_tab | grep '^[0-9N][0-9\.O]' | grep '<->' > ${dump}_hosts-conv-traffic
paste ${dump}_hosts-i-h-try ${dump}_hosts-conv-traffic | sed 's/\t//' > ${dump}_hosts-conv-all
# That's the body of it.
# Now first check if it's the $r_case. The case when no IP's are resolved,
# usual in some particular kind of browsing.
r_case=$(awk '{ print $2 }' ${dump}_hosts-i-h-try | sort -u)
if [ "$r_case" == "NOTICE-could-not-be-resolved-NOTICE" ]; then
    # It's the $r_case. Take the $n's.
    awk '{ print $1 }' ${dump}_hosts-i-h-try | grep -v '127.0.0.1\|224.0.0.1' \
        > ${dump}_rn.txt
    cat ${dump}_rn.txt
    echo "(cat ${dump}_rn.txt)"
    ls -l ${dump}_rn.txt
    #read FAKE
fi

# Now the header.
hosts_conv_head_1_l=$(grep -A3 -m1 '=-=-=-=-=-=' $source | tail -2 | head -1 | wc -c) 
hosts_conv_head_2_l=$(grep -A3 -m1 '=-=-=-=-=-=' $source | tail -1 | head -1 | wc -c) 
# Must be same:
if [ "$hosts_conv_head_1_l" != "$hosts_conv_head_2_l" ]; then
    echo "Probably _minor_ inconvenience. Not exiting with failure, but..."
    echo "...Just pls. mark my words:"
    echo "possibly NOT completely correct ouutput:"
    echo "The two lines in the header for conv-ip_l.txt have different length."
    #read FAKE_perm
fi

grep -A3 -m1 '=-=-=-=-=-=' $source | tail -2 > ${dump}_hosts-head
hosts_conv_all_l=$(head -1 ${dump}_hosts-conv-all | wc -c)
echo \$hosts_conv_all_l: $hosts_conv_all_l
echo $hosts_conv_all_l > .${dump}_conv-ip_l.tw
# "p" plus, else it's one line missing in bottom with the xterm command, see below
let wc_l_ip+=3
echo $wc_l_ip > .${dump}_conv-ip_l.th
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
if ( diff ${dump}_conv-ip_l.txt ${dump}_conv-ip_l.txt_${ts} ); then
    mv -v ${dump}_conv-ip_l.txt_${ts} ${dump}_conv-ip_l.txt
fi
ls -l ${dump}_conv-ip_l.txt
ls -l .${dump}_conv-ip_l.tw .${dump}_conv-ip_l.th
cat .${dump}_conv-ip_l.tw
echo "(cat .${dump}_conv-ip_l.tw)"
cat .${dump}_conv-ip_l.th
echo "(cat .${dump}_conv-ip_l.th)"
rm -v ${dump}_conv-ip_l.lock
# Not very ingenious, but it can be:
# w=$(<.${dump}_conv-ip_l.tw)
# h=$(<.${dump}_conv-ip_l.th)
# xterm -g ${w}x${h}+50+20 -fn "-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso10646-1" -e "view ${dump}_conv-ip_l.txt"
