#!/bin/bash
#
# mount-local --  mount local data
#
# this script is part of the uncenz set of scripts:
# https://github.com/miroR/uncenz
#
# released under BSD license, pls. see LICENSE
#
# Copyright (C) 2025 Miroslav Rovis, <http://www.CroatiaFidelis.hr/>
#

function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

myuid=$(id -u)
if [ "$myuid" != "0" ]; then
    echo \$myuid: $myuid
    echo "You need to be root to run this script."
    exit 0
fi

for dev in a b c d e f g h ; do
    if [ -e "/dev/sd${dev}" ]; then
        echo;
        echo -n "/dev/sd${dev}:  ";
        smartctl -i /dev/sd${dev} | grep 'Serial\|Capacity' ;
        ser_raw=$(smartctl -i /dev/sd${dev} | grep 'Serial'|awk '{print $3}'); ser=${ser_raw: -3};
        echo \$ser: $ser; ask "open?" ;
        if [ "$?" == 0 ]; then
            if [ -e "/mnt/g-${ser}" ]; then
                cryptsetup open /dev/sd${dev}1 g-${ser} && mount /dev/mapper/g-${ser} /mnt/g-${ser};
                ls -l /mnt/g-${ser}|head -n6;
                ls -l /mnt/g-${ser}|tail -n6;
                echo "-==~^~==-";
                ls -ld /mnt/g-${ser};
            fi;
        fi;
    fi;
done

