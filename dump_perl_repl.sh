#/bin/bash
#
# dump_perl_repl.sh -- search for MACs/serials in the trace (PCAP) that you
#					would rather see replaced with fake ones before publishing
#
# mainly written for my uncenz set of scripts, but can very well be
# independently used
#
# Copyright (C) 2015 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#
# released under BSD license, see LICENSE, or assume general BSD license
#
# This script is run in a directory where all PCAPs to be searched and replaced
# are put (mybe symlinks are fine?)
#
# I am not really a programmer, but I need this, and haven't find anywhere just
# this what I need, and that is:
#
# I don't want a complete rewrite of PCAPs by any means. I can't hide the
# network topology in details of time and IPs for the events that happened and
# that I caught with my uncenz (simple) program.
#
# Because that wouldn't prove any censorship any more would it?
#
# So fake some serials, and fake the MACs, so just a thin layer of very little
# anonymization on my PCAPs.
#
# I may add more anonymization some day, if I try and play with Tor such as
# with Whonix or Tails unless they censor me from using those.
#
# Again, I am not really a programmer, this script is my first real use of perl
# oneliners, and it's clumsy and dirty, and it's way over bloated, but it
# works, in my Gentoo FOSS *nix.
#
# Pls. see a sample search and replace list, which would fake my already faked
# strings, sure this won't help for your own dumps (but you can practice with
# this sample list and the dumps at http://www.CroatiaFidels.hr/foss/cap/):
# dump_strings_ORIG2FAKE.ls-1
#
function ask() # borrowed from Advanced Bash Scripting Guide, by Mendel Cooper
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

# I should also check the PCAPs in the current dir. Some day... Till then, this
# script fails in unpredicted way if files in its current dirs are not workable
# PCAPs.
if [ ! -e "$1" ]; then
	echo "Must give a file with a list of ethers to search and replace as $1"
	echo "the orig ethernet MAC, "," the fake ethernet MAC, such as: "
	echo "\x00\x11\x33\x44\x55\x66,\xff\xee\xdd\xcc\xbb\xaa"
	echo "i.e. one pair per line."
	# can also be any other string, but in hex, such as for some serial, of
	# maybe more or less bytes, just equal number orig and fake
	exit 0
fi

# But that dump_strings_ORIG2FAKE.ls-1 may need to be sanitized first from
# my own comments:
mv -iv dump_strings_ORIG2FAKE.ls-1 dump_strings_ORIG2FAKE.ls-1_RAW
cat dump_strings_ORIG2FAKE.ls-1_RAW | sed "s/^#.*//" | grep -E '[[:print:]]' > dump_strings_ORIG2FAKE.ls-1
read FAKE

touch Found.txt
echo "Created (if it didn't exist) and will be writing to Found.txt."
echo "You should issue \"tailf Found.txt\" in another teminal."
echo "to see what gets found and printed by the sript. Especially"
echo "if you are debugging after uncommenting the \"read FAKE\" lines."
for i in $(ls -1 *.pcap|sed 's/\.pcap//'); do
	for ether_pair in $(cat $1); do
		ls -l $i.pcap.bak $i.pcap
		ether_orig=$(echo $ether_pair | cut -d, -f1)
		ether_fake=$(echo $ether_pair | cut -d, -f2)
		echo \$ether_pair: $ether_pair
		#read FAKE
		echo \$ether_orig: $ether_orig
		##read FAKE
		echo \$ether_fake: $ether_fake
		##read FAKE
		echo -n "$i.pcap: " >> Found.txt ;
		wc_c=$(echo $ether_orig | wc -c)
		wc_c_minus=$(echo $wc_c-2|bc)
		echo \$wc_c_minus: $wc_c_minus
		# hum is for (more) human readable
		ether_orig_hum=$(echo $ether_orig | sed "s/\\x\([0-f][0-f]\)/\1:/g"|sed "s/\(.\{$wc_c_minus\}\):/\1/"|sed 's/\\//g')
		echo \$ether_orig_hum: $ether_orig_hum
		##read FAKE
		export ether_orig
		export ether_orig_hum
		cat ${i}.pcap | \
		perl -ne 'print "$ENV{ether_orig_hum} " if /$ENV{ether_orig}/' \
			>> Found.txt ; echo >> Found.txt
		##read FAKE
		echo "Replace, next" >> Found.txt
		export ether_orig
		export ether_orig_hum
		##read FAKE
		echo \$ether_orig: $ether_orig
		##read FAKE
		echo \$ether_orig_hum: $ether_orig_hum
		#read FAKE
		wc_c=$(echo $ether_fake | wc -c)
		wc_c_minus=$(echo $wc_c-2|bc)
		echo \$wc_c_minus: $wc_c_minus
		ether_fake_hum=$(echo $ether_fake | sed "s/\\x\([0-f][0-f]\)/\1:/g"|sed "s/\(.\{$wc_c_minus\}\):/\1/"|sed 's/\\//g')
		echo \$ether_fake_hum: $ether_fake_hum
		echo \$ether_fake: $ether_fake
		##read FAKE
		echo \$ether_fake_hum: $ether_fake_hum
		export ether_orig
		##read FAKE
		export ether_fake
		##read FAKE
		#echo "perl should print $ether_orig and $ether_fake now:"
		#perl -pe print $ether_orig
		#perl -pe print $ether_fake
		# just it'll think they were files
		echo "Replace is next but for real."
		#read FAKE
		perl -pi.bak -e "s/$ether_orig/$ether_fake/g" ${i}.pcap
		export ether_orig
		export ether_orig_hum
		##read FAKE
		echo \$ether_orig: $ether_orig
		##read FAKE
		echo \$ether_orig_hum: $ether_orig_hum
		export ether_fake
		export ether_fake_hum
		##read FAKE
		echo \$ether_fake: $ether_fake
		##read FAKE
		echo \$ether_fake_hum: $ether_fake_hum
		##read FAKE
		echo "If $ENV{ether_orig_hum} found it should be printed in Found.txt."
		cat ${i}.pcap | \
		perl -ne 'print "$ENV{ether_orig_hum} " if /$ENV{ether_orig}/' \
			>> Found.txt ; echo >> Found.txt
		#read FAKE
		echo "If $ENV{ether_fake_hum} found it should be printed in Found.txt."
		cat ${i}.pcap | \
		perl -ne 'print "$ENV{ether_fake_hum} " if /$ENV{ether_fake}/' \
			>> Found.txt ; echo >> Found.txt
		#read FAKE
		ls -l $i.pcap.bak $i.pcap
		# Bad substitution one of very possible errors, this may reveal the
		# exact step by the size increase/decrease:
		size_orig=$(ls -l $i.pcap.bak|awk '{ print $5}')
		size_fake=$(ls -l $i.pcap|awk '{ print $5}')
		if [ "$size_orig" != "$size_fake" ]; then
			#ls -l $i.pcap.bak $i.pcap
			echo "Sizes differ. Bad faking! Pls. investigate what went wrong."
			echo "Exiting..."
			exit 1
		fi
		# No substitution took place if the hash of both $i.pcap and
		# $i.pcap.bak match:
		sha256_orig=$(sha256sum $i.pcap.bak|cut -d' ' -f1)
		sha256_fake=$(sha256sum $i.pcap|cut -d' ' -f1)
		sha256sum $i.pcap.bak
		sha256sum $i.pcap
		if [ "$sha256_orig" == "$sha256_fake" ]; then
			#ls -l $i.pcap.bak $i.pcap
			echo "Hashes are the same. No faking took place!"
			echo "Investigate whether something went wrong?"
			echo "(Or it could be there weren't any founds.)"
			echo "Type \"y\" for exit. Or just hit Enter and we continue."
			ask;
			if [ "$?" == 0 ]; then
				exit 1
			fi
		fi
		echo "==== The \$ether_pair: $ether_pair processed ==="
		echo "------------------------------------------------"
	done
	echo "==== trace $i.pcap processed ==="
	echo "============================================="
	echo "============================================="
done
