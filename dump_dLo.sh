#!/bin/bash
#
# dump_dLo.sh -- download the listing of a directory with traces and
#					screencasts/other and build a script to download all the
#					files. If modified the idea can be used for easy downloads
#					based on one single listing and one url
#
# This script is, in broader manner, part of uncenz set, since I wrote it to
# ease downloads of my uncenz produced traces/screencasts/other
# (
# but I only recently got this idea, when posting about:
#
# Devuan image in Qemu
# http://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/
#
# where find the line in bottom:
# "The files necessary for this study are listed in: ls-1 [...]".
# My old published PCAPs and screencasts are not (yet?) arranged in this way...
# )
#
# Copyright (C) 2015 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
# Use this at your own risk!
# released under BSD license, see LICENSE, or assume general BSD license,
#
# This script is oriented for use on unix family of OSes. (I very rarely use
# Windows so...)
# If you're a Windows expert, or use Cygwin on Windows, you can likely modify
# it and still use it... but I can't help with it.
#

function ask()	# this function borrowed from Advanced BASH Scripting Guide
				# by Mendel Cooper
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

if [ $# -eq 0 ]; then
#if [ ! -e "$1" ]; then
	echo
	echo "Must give the url of the directory where you want to download"
	echo "the files from as \$1, the first argument to this command"
	echo
	echo "Just give it the ls-1 list of files from"
	echo "that directory at www.CroatiaFidelis.hr/foss/cap/ as \$1 ,"
	echo "("
	echo "the full url of it, such as:"
	echo "http://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/ls-1"
	echo "),"
	echo "the script should manipulate it and get you all the files listed."
	echo
	echo "Also the url without listing can be given e.g.:"
	echo "http://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/"
	echo "or:"
	echo "http://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan"
	echo "."
	echo "Not all the necessary checking is performed, no time,"
	echo "and if some of the normal requirements is not there (such as"
	echo "missing http:// at the beginning of the url, the script"
	echo "may just fail (but not necessarily)."
	echo
	echo "And surely you need to run this in a directory"
	echo "where you have all the privs."
	echo
	exit 0
fi

echo "The code in this script is clumsy, but does the work."
echo "It is best to read (and correct) this script before use."
echo
the_url_raw="$1"
#echo $the_url_raw
echo "There are 'read FAKE' lines in the script, which are not really used for"
echo "reading anything. But to give the user a pause to see how the script is"
echo "faring, to read the script at the lines that currently execute and"
echo "decide whether to hit Enter and continue running the script or to"
echo "bail out by issuing Ctrl-C to kill the script and investigate."
read FAKE
echo "Once you familiarize with the script you can comment out those lines."
read FAKE
# the uri of the list of files ls-1 is fine, but that's not the base address
# for downloading
# Moreover, we need one, and only one, '/' at end of url
the_url=$(echo $the_url_raw \
	|sed 's/\(.*\)/\1\//' \
	|sed 's/\(.*\):\/\/\(.*\)\/\/\(.*\)/\1:\/\/\2\/\3/' \
	|sed 's/ls-1//' \
	|sed 's/\(.*\):\/\/\(.*\)\/\/\(.*\)/\1:\/\/\2\/\3/')
echo $the_url
read FAKE
wget -nc ${the_url}ls-1
echo "###"
echo "### The listing of files ls-1 has just been downloaded from"
echo "### $the_url"
echo "### You can now edit the ls-1 and only the files that remain in the list"
echo "### will be downloaded."
echo "###"
read FAKE

> num_slashes.txt
> the_dir.txt
> the_dirR.txt
> dLo.sh
> CMD
read FAKE
echo $the_url|sed "s@/@\n@g"
echo $the_url|sed "s@/@\n@g"| wc -l > num_slashes.txt
echo -n "cat num_slashes.txt: "; cat num_slashes.txt
num_slashes_raw=$(cat num_slashes.txt)
echo \$num_slashes_raw: $num_slashes_raw
read FAKE
num_slashes=$(echo $num_slashes_raw+1|bc) # add 1 in case no '/' at end
echo \$num_slashes: $num_slashes
read FAKE
# the_dir is the last awk'd field if not empty (it is empty if the_url ends
# in '$'
#echo "awk line next"
#read FAKE
#echo "echo \$the_url | awk -F'/' '{ print \$$num_slashes }' > the_dir.txt" > CMD
#cat CMD
#echo "awk line above"
#chmod 755 CMD
#read FAKE
#./CMD
#read FAKE
#cat the_dir.txt
#read FAKE
> the_dirR.txt
while [ ! -s "the_dirR.txt" ]; do
	echo \$num_slashes: $num_slashes
	read FAKE
	num_slashes=$(echo $num_slashes-1|bc)
	echo \$num_slashes: $num_slashes
	read FAKE
	echo "the_url=\"$the_url\"" > CMD
	echo "cat CMD: "; cat CMD
	read FAKE
	echo "echo \$the_url | awk -F'/' '{ print \$$num_slashes }'" >> CMD
	echo "read FAKE" >> CMD
	echo "echo \$the_url | awk -F'/' '{ print \$$num_slashes }' > the_dir.txt" >> CMD
	chmod 755 CMD
	read FAKE
	echo \$the_url: $the_url
	echo \$the_dir: $the_dir
	read FAKE
	./CMD
	read FAKE
	echo \$the_url: $the_url
	read FAKE
	cat the_dir.txt
	the_dir=$(cat the_dir.txt)
	echo \$the_dir: $the_dir
	read FAKE
	cat the_dir.txt | grep -E '[[:print:]]' > the_dirR.txt
	read FAKE
done
the_dir=$(cat the_dir.txt)
echo \$the_dir: $the_dir

# The ls-1 is already there, because it's basis for the downloads, and the
# index.php is more of a distraction then is useful, for most readers. The
# ls-1.sum and ls-1.sum.asc are necessary.
cat ls-1 | sed "s/\(ls-1\)/\1.sum\n\1.sum.asc/" | grep -v index.php > ls-1_cor
read FAKE
echo $the_dir
read FAKE
# Correct the url for ending '/' else it may get '//' before next sed'ing.
#the_url=$(echo $the_url | sed 's/\(.*\)\//\1/')
echo \$the_url: $the_url
read FAKE
cat ls-1_cor | sed "s@\(.*\)@wget -nc $the_url\1@" > dLo.sh.TMP

cat > dLo.sh <<EOF
#!/bin/bash
#
# script to download samples from http://www.CroatiaFidelis.hr/foss/cap/
#
# See https://github.com/miroR/uncenz
#
echo "Use this script at your own responsability."
echo
echo "That said, nothing should go wrong with this script."
echo "If you are now in a directory where you have all the privs,"
echo "you should be fine just running this (primitive) script."
echo
echo "Hit Enter, and this will create a directory, and download"
echo "all the files (or those you left in ls-1) that are listed at:"
echo
echo "$the_url"
echo
echo "which you have chosen to download. Hit Enter now!"
read FAKE
EOF

echo >> dLo.sh
echo "mkdir $the_dir" >> dLo.sh
echo >> dLo.sh
echo "cd $the_dir" >> dLo.sh
echo >> dLo.sh
cat dLo.sh.TMP >> dLo.sh
read FAKE
rm ls-1_cor dLo.sh.TMP
chmod 755 dLo.sh
echo "### The script to download network traces and screencasts"
echo "### (or maybe other stuff as well) from the url:"
echo "###  $the_url"
echo "### that you visited on www.CroatiaFidelis.hr"
echo "### *should* (I'm only an amateur...) be ready."
echo "### You may try to run it"
echo "### if you are confident enough about it."
echo "### In which case, hit type 'y' next."
echo "### (Also fine is typing 'n', inspect the newly"
echo "### created dLo.sh and run it after the cleaning"
echo "### in the step after next below.)"
ask
if [ "$?" == 0 ] ; then
./dLo.sh
fi
echo "Do the cleaning now?"
ask
if [ "$?" == 0 ] ; then
	rm -v  num_slashes.txt
	rm -v  the_dir.txt
	rm -v  the_dirR.txt
	rm -v  CMD
fi
echo "If you just ran ./dLo.sh (or if you will run it later)"
echo "then likely you can now (or after you run ./dLo.sh) descend into"
echo "the newly created directory:"
echo "$the_dir on your local storage, and check and verify"
echo "the files you downloaded."
