#!/bin/bash
#
# dump_dLo.sh -- download the listing of a directory with traces and
#                    screencasts/other and build a script to download all the
#                    files. If modified the idea can be used for easy downloads
#                    based on one single listing and one url
#
# This script is, in broader manner, part of uncenz set, since I wrote it to
# ease downloads of my uncenz produced traces/screencasts/other
#
# I got this idea, when posting about:
# Devuan image in Qemu
# https://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/
# where find the line in bottom:
# "The files necessary for this study are listed in: ls-1".
#
# This script is oriented for use on unix family of OSes.
# If you're a Windows expert, or use Cygwin on Windows, you can likely modify
# it and still use it, but I almost never use Windows anymore, so I can't help
# with it.
#
# Some cleanup/improvement in 2022. After a period of (rare) use, will remove
# much of the unnecessary commented out stuff.
#
# Copyright (C) 2015, 2022 Miroslav Rovis, <https://www.CroatiaFidelis.hr/>
# Use this at your own risk!
# released under BSD license, see LICENSE, or assume general BSD license,
#

function ask()  # this function borrowed from "Advanced BASH Scripting Guide"
                # (a free book) by Mendel Cooper
{
    echo -n "$@" '[y/[n]] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function decline()    # the opposite, inverse, the negative if you will, of ask()
{
    echo -n "$@" '[[y]/n] ' ; read ans
    case "$ans" in
        n*|N*) return 1 ;;
        *) return 0 ;;
    esac
}

if [ $# -eq 0 ]; then
    echo
    echo "Must give the url of ls-1 in the directory where you want"
    echo "to download the files from. Pls. read the script!"
    # Just give it the ls-1 (or ls-1pg1 or such; the only constraint is: the
    # files must begin with the 4 chars \"ls-1\", also: the name of the sum
    # and the signature are later construed by adding ".sum" and ".sum.asc").
    # Give it that list of files from that directory at some site such as my NGO's
    # www.CroatiaFidelis.hr/foss/cap/ as \$1 ,
    # (
    # The full url of it, such as:
    # https://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/ls-1
    # or:
    # https://www.croatiafidelis.hr/foss/cap/cap-161202-stackoverflow/ls-1pg3
    # ),
    # the script should manipulate it and get you all the files listed.
    # Also the url without listing can be given e.g.:
    # https://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan/
    # or:
    # https://www.CroatiaFidelis.hr/foss/cap/cap-161015-qemu-devuan
    # , but only if that dir contains exactly the ls-1 listing,
    # not some other like ls-1someMore.
    # Not all the necessary checking is performed, no time,
    # and if some of the normal requirements is not there (such as
    # missing https:// or http:// at the beginning of the url,
    # the script may just fail (but not necessarily).
    # And surely you need to run this in a directory
    # where you have all the privs.
    exit 0
fi

# The code in this script is kludgy, but does the work.
# It would be best to read (and correct) this script before use.
#echo
the_url_raw="$1"
#echo $the_url_raw
# There are 'read NOP' lines in the script, which are not really used for
# reading anything. But to give the user a pause to see how the script is
# faring, to read the script at the lines that currently execute and
# decide whether to hit Enter and continue running the script or to
# bail out by issuing Ctrl-C to kill the script and investigate.
# You can freely comment them out or uncomment them, or even, if you're
# learning, insert them temporarily where needed.
#read NOP

> dLo.sh
#echo $the_url_raw|sed "s@/@\n@g"
NUM_SLASHES_RAW=$(echo $the_url_raw|sed "s@/@\n@g"| wc -l)
NUM_SLASHES=$(echo $NUM_SLASHES_RAW+1|bc) # add 1 in case no '/' at end
#read NOP

> the_listR.txt
touch CMD
chmod 755 CMD
while [ ! -s "the_listR.txt" ]; do
    NUM_SLASHES=$(echo $NUM_SLASHES-1|bc)
    #echo \$NUM_SLASHES: $NUM_SLASHES
    #read NOP
    echo "the_url_raw=\"$the_url_raw\"" > CMD
    #echo "cat CMD: "; cat CMD
    #read NOP
    echo "echo \$the_url_raw | awk -F'/' '{ print \$$NUM_SLASHES }'" >> CMD
    #echo "read NOP" >> CMD
    echo "echo \$the_url_raw | awk -F'/' '{ print \$$NUM_SLASHES }' > the_list.txt" >> CMD
    #read NOP
    #echo \$the_url_raw: $the_url_raw
    #echo \$the_list: $the_list
    #read NOP
    ./CMD
    #read NOP
    #echo \$the_url_raw: $the_url_raw
    #read NOP
    #cat the_list.txt
    the_list=$(<the_list.txt)
    #echo \$the_list: $the_list
    #read NOP
    grep '[[:print:]]' the_list.txt > the_listR.txt
    #read NOP
done
the_list=$(<the_list.txt)
#echo \$the_list: $the_list

# the uri of the list of files such as ls-1 is fine, but that's not the base address
# for downloading
# Moreover, we need one, and only one, '/' at end of url
the_url=$(echo $the_url_raw \
    |sed 's/\(.*\)/\1\//' \
    |sed 's/\(.*\):\/\/\(.*\)\/\/\(.*\)/\1:\/\/\2\/\3/' \
    |sed "s/${the_list}//" \
    |sed 's/\(.*\):\/\/\(.*\)\/\/\(.*\)/\1:\/\/\2\/\3/')
#echo $the_url
#read NOP
wget -nc ${the_url}${the_list}
echo "###"
echo "### The listing of files ${the_list} has just been downloaded from"
echo "### $the_url"
echo "### You can now edit the ${the_list} and only the files that remain in the list"
echo "### will be downloaded. (And if you add some other files from:"
echo "$the_url"
echo "### they will be downloaded too."
echo "###"
read NOP

> the_dirR.txt
while [ ! -s "the_dirR.txt" ]; do
    #echo \$NUM_SLASHES: $NUM_SLASHES
    #read NOP
    NUM_SLASHES=$(echo $NUM_SLASHES-1|bc)
    #echo \$NUM_SLASHES: $NUM_SLASHES
    #read NOP
    echo "the_url=\"$the_url\"" > CMD
    #echo "cat CMD: "; cat CMD
    #read NOP
    #echo "echo \$the_url | awk -F'/' '{ print \$$NUM_SLASHES }'" >> CMD
    #echo "read NOP" >> CMD
    echo "echo \$the_url | awk -F'/' '{ print \$$NUM_SLASHES }' > the_dir.txt" >> CMD
    chmod 755 CMD
    #read NOP
    #echo \$the_url: $the_url
    #echo \$the_dir: $the_dir
    #read NOP
    ./CMD
    #read NOP
    #echo \$the_url: $the_url
    #read NOP
    #cat the_dir.txt
    the_dir=$(<the_dir.txt)
    #echo \$the_dir: $the_dir
    #read NOP
    cat the_dir.txt | grep -E '[[:print:]]' > the_dirR.txt
    #read NOP
done
the_dir=$(<the_dir.txt)
#echo \$the_dir: $the_dir

# The ${the_list} is already there, because it's basis for the downloads, and the
# index.php is more of a distraction then is useful, for most readers. The
# ${the_list}.sum and ${the_list}.sum.asc are necessary.
#echo "cat ${the_list}"
#cat ${the_list}
#read NOP
echo ${the_list} >> ${the_list}
#echo "cat ${the_list}"
#cat ${the_list}
#read NOP
cat ${the_list} | sed "s/\($the_list\)/\1.sum\n\1.sum.asc/" \
    | grep -Ev '\.php\>' | sed 's/^\.\///' > ${the_list}_cor
#read NOP
# If ${the_list}_cor has a '/' in it, then the dLo.sh is slightly more complex
# I'll try and grep the lines containing '/'.
#read NOP
grep '/' ${the_list}_cor | awk -F'/' '{ print $1 }' | sort -u >> the_subdirs.txt
#read NOP

cat > dLo.sh <<EOF
#!/bin/bash
#
# script to download samples from https://www.CroatiaFidelis.hr/foss/cap/
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
echo "all the files (or those you left in ${the_list}) that are listed at:"
echo
echo "$the_url"
echo
echo "which you have chosen to download. Hit Enter now!"
read NOP
EOF

echo >> dLo.sh
if [ -e "$the_dir" ]; then
    echo "$the_dir already exists."
    echo "Here the listing of files in it:"
    ls -ld $the_dir
    ls -la $the_dir
    echo "If you are downloading from a network"
    echo "directory from which you already downloaded from recently,"
    echo "then it should be fine to reuse the same directory"
    echo "and download into it another number of files from the list."
    echo "Hit Enter to continue."
    read NOP
fi
echo "mkdir -pv $the_dir" >> dLo.sh
echo >> dLo.sh
echo "cd $the_dir" >> dLo.sh
echo >> dLo.sh

if [ -s "the_subdirs.txt" ]; then
    for the_subdir in $(<the_subdirs.txt); do
        cat ${the_list}_cor | grep $the_subdir \
            | sed "s@\(.*\)@wget -nc $the_url\1@" >> dLo.sh_subdir
    done
    #echo "cat the_subdirs.txt|sed 's/\(.*\)/\1\//'"
    cat the_subdirs.txt|sed 's/\(.*\)/\1\//' >  the_subdirs.txtR
    #read NOP
    all_subdirs=$(cat the_subdirs.txt|sed 's/\(.*\)/\1\//'|sed 's/ //g')
    #echo \$all_subdirs: $all_subdirs
    #read NOP
    #echo cat the_subdirs.txtR
    #cat the_subdirs.txtR
    #read NOP
    mv the_subdirs.txtR the_subdirs.txt
    #echo cat the_subdirs.txt
    #cat the_subdirs.txt
    #read NOP
    #echo "cat the_subdirs.txt | tr '\012' '\|' | sed \"s/|$//\""
    all_subdirs=$(cat the_subdirs.txt | tr '\012' '|' | sed "s/|$//")
    #echo \$all_subdirs: $all_subdirs
    #read NOP
    cat ${the_list}_cor | grep -Ev $all_subdirs \
        | sed "s@\(.*\)@wget -nc $the_url\1@" >> dLo.sh_topdir
else
    cat ${the_list}_cor \
        | sed "s@\(.*\)@wget -nc $the_url\1@" >> dLo.sh_topdir
fi    
#read NOP

mv -i dLo.sh_topdir dLo.sh_topdir_RAW
sort -u dLo.sh_topdir_RAW > dLo.sh_topdir
if [ -e "dLo.sh_subdir" ]; then
    mv -i dLo.sh_subdir dLo.sh_subdir_RAW
    sort -u dLo.sh_subdir_RAW > dLo.sh_subdir
fi

cat dLo.sh_topdir >> dLo.sh
if [ -e "dLo.sh_subdir" ]; then
    for the_subdir in $(<the_subdirs.txt); do
        echo "mkdir $the_subdir" >> dLo.sh
        echo "cd $the_subdir" >> dLo.sh
        grep $the_subdir dLo.sh_subdir >> dLo.sh
        echo "cd -" >> dLo.sh
    done
#    cat dLo.sh_subdir >> dLo.sh
fi
#read NOP
chmod 755 dLo.sh
echo "### The script to download network traces and screencasts"
echo "### (or maybe other stuff as well) from the url:"
echo "###  $the_url"
echo "### that you visited on www.CroatiaFidelis.hr"
echo "### You may try and run it"
echo "### if you are confident enough about it."
echo "### In which case, hit type 'y' next."
echo "### (Also fine is typing 'n', inspect the newly"
echo "### created dLo.sh and run it after the cleaning"
echo "### in the step after next below.)"
ask
if [ "$?" == 0 ] ; then
    ./dLo.sh
    echo "Likely you can now descend into"
    echo "the newly created directory:"
    echo "$the_dir on your local storage, and check and verify"
    echo "the files you downloaded."
    echo "All the files should be there:"
    ls -l $the_dir
    echo "If the files are there, then do the following:"
    echo "cd $the_dir"
    echo "sha256sum -c ${the_list}.sum"
    echo "gpg --verify ${the_list}.sum.asc"
    echo "and if all verifies correctly, you're done"
    echo "with fetching and verifying the files."
else
    echo "After you run ./dLo.sh, do:"
    echo "cd $the_dir"
    echo "sha256sum -c ${the_list}.sum"
    echo "gpg --verify ${the_list}.sum.asc"
    echo "and if all verifies correctly, you're done"
    echo "with fetching and verifying the files."
fi
echo "To go without doing cleaning type:"
echo "n/N"
echo "(Hitting anything else does the cleaning.)"
decline
if [ "$?" == 1 ] ; then
    echo "The cleaning is left to the user, by own decision."
else
    if [ -e "$the_dir" ]; then
        mv dLo.sh ${the_list} $the_dir
    fi
    rm the_dir.txt
    rm the_list.txt
    rm the_dirR.txt
    rm the_listR.txt
    rm the_subdirs.txt
    rm dLo.sh_topdir
    rm dLo.sh_topdir_RAW
    rm dLo.sh_subdir
    rm dLo.sh_subdir_RAW
    rm CMD
    rm ${the_list}_cor
fi
