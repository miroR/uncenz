#!/bin/bash
#
# uncenz-scr_CMD_create.sh -- this script is called by uncenz-2nd on Wayland
#                               wf-recorder created screencasts
#
# Copyright (C) 2023 Miroslav Rovis, <https://www.CroatiaFidelis.hr/>
#
# released under BSD license, pls. see LICENSE
#
# this script is part of the uncenz set of scripts:
# https://github.com/miroR/uncenz
#

function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

echo \$1: $1
echo \$2: $2

if [ -n "$1" ]; then
    scr_file="$1"
fi
if [ -n "$2" ]; then
    parts_start="$2"
fi

scr_file=$1
echo \$scr_file: $scr_file
ext=${scr_file##*.}
scr=${scr_file%*.mkv}
scr_file=$scr.$ext
ls -l $scr_file
echo "(ls -l $scr_file)"
echo "(ls -l \$scr_file)"
ls -l $scr.$ext
echo "(ls -l $scr.$ext)"
echo "(ls -l \$scr.\$ext)"

echo \$scrg2_base: $scrg2_base
read NOP

if [ -e ".$scrg2_base.CMD" ]; then
    ask "Truncate .$scrg2_base.CMD ?"
    if [ "$?" == 0 ]; then
        > .$scrg2_base.CMD
    fi
fi
unset part_001_001_ok
part_001_001_initial=y
while [ "$part_001_001_ok" != "y" ]; do
    if [ "$part_001_001_initial" != "y" ]; then
        echo "give new value for \$parts_start: "
        read parts_start
    fi
    echo \$parts_start: $parts_start
    echo "mkvmerge -q -o ${scr}_.$ext --split timecodes:$parts_start ${scr}.$ext" |& tee -a .$scrg2_base.CMD
    mkvmerge -q -o ${scr}_.$ext --split timecodes:$parts_start ${scr}.$ext
    echo "ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext" |& tee -a .$scrg2_base.CMD
    ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext
    part_001=$(ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext)
    echo "# \$part_001: $part_001" |& tee -a .$scrg2_base.CMD
    part_001M=$(echo $part_001*1000/1|bc)
    echo "# \$part_001M: $part_001M" |& tee -a .$scrg2_base.CMD
    read NOP
    echo \$parts_start: $parts_start
    parts_start_min=$(echo $parts_start | awk -F: '{print $1}')
    parts_start_sec=$(echo $parts_start | awk -F: '{print $2}'| awk -F. '{print $1}')
    parts_start_msec=$(echo $parts_start | awk -F. '{print $2}')
    echo \$parts_start_min: $parts_start_min
    echo \$parts_start_sec: $parts_start_sec
    echo \$parts_start_msec: $parts_start_msec
    parts_startM=$(echo "(($parts_start_min*60+$parts_start_sec)*1000+$parts_start_msec)/1"|bc)
    echo "# \$parts_startM: $parts_startM" |& tee -a .$scrg2_base.CMD
    read NOP
    ask "Try with these values?"
    if [ "$?" == 0 ]; then
            #echo "# \$part_001M -gt \$parts_startM" |& tee -a .$scrg2_base.CMD
            echo "ffmpeg -y -i ${scr}_-001.$ext -c:v hevc -g 2 ${scr}_-001-g2.$ext &> /dev/null" |& tee -a .$scrg2_base.CMD
            echo "Running:"
            echo "ffmpeg -y -i ${scr}_-001.$ext -c:v hevc -g 2 ${scr}_-001-g2.$ext"
            echo "echo \"Will notify when ${scr}_-001-g2.$ext is created\"" |& tee -a .$scrg2_base.CMD
            echo "Will notify when ${scr}_-001-g2.$ext is created"
            ffmpeg -y -i ${scr}_-001.$ext -c:v hevc -g 2 ${scr}_-001-g2.$ext &> /dev/null
            echo "ls -l ${scr}_-001-g2.$ext" |& tee -a .$scrg2_base.CMD
            ls -l ${scr}_-001-g2.$ext
            #read NOP
            echo "mkvmerge -q -o ${scr}_-001-g2_.$ext --split timecodes:$parts_start ${scr}_-001-g2.$ext" |& tee -a .$scrg2_base.CMD
            mkvmerge -q -o ${scr}_-001-g2_.$ext --split timecodes:$parts_start ${scr}_-001-g2.$ext
            echo "ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext" |& tee -a .$scrg2_base.CMD
            ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext
            part_001_001=$(ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext)
            echo "# \$part_001_001: $part_001_001" |& tee -a .$scrg2_base.CMD
            part_001_001M=$(echo $part_001_001*1000/1|bc)
            echo "# \$part_001_001M: $part_001_001M" |& tee -a .$scrg2_base.CMD
    else
        echo "user declined to manipulate starting with these:"
        echo "\$parts_start: $parts_start"
        echo "\$parts_startM: $parts_startM"
        echo "\$part_001M: $part_001M"
        echo "So we now \"continue\""
        continue
    fi
    ask "ok?"
    if [ "$?" == 0 ]; then
        part_001_001_ok=y
        echo "mkvmerge -q -o ${scr}-g2_0.$ext ${scr}_-001-g2_-002.$ext + ${scr}_-002.$ext" |& tee -a .$scrg2_base.CMD
        #read NOP
        mkvmerge -q -o ${scr}-g2_0.$ext ${scr}_-001-g2_-002.$ext + ${scr}_-002.$ext
        mpv --window-scale=0.95 ${scr}-g2_0.$ext
        echo "ls -l ${scr}_-00[12].mkv ${scr}_-001-g2.mkv" |& tee -a .$scrg2_base.CMD
        ls -l ${scr}_-00[12].mkv ${scr}_-001-g2.mkv
        echo "ls -l ${scr}_-001-g2_-00[12].mkv" |& tee -a .$scrg2_base.CMD
        ls -l ${scr}_-001-g2_-00[12].mkv
        echo "echo \"All to be removed when you hit Enter\"" |& tee -a .$scrg2_base.CMD
        echo "read NOP" |& tee -a .$scrg2_base.CMD
        echo "rm -v ${scr}_-00[12].mkv ${scr}_-001-g2.mkv" |& tee -a .$scrg2_base.CMD
        rm -v ${scr}_-00[12].mkv ${scr}_-001-g2.mkv
        echo "rm -v ${scr}_-001-g2_-00[12].mkv" |& tee -a .$scrg2_base.CMD
        rm -v ${scr}_-001-g2_-00[12].mkv
        echo "Pls. edit the script file:"
        ls -l .$scrg2_base.CMD
        echo "cat .$scrg2_base.CMD"
        read NOP
        cat .$scrg2_base.CMD
        echo "(cat .$scrg2_base.CMD)"
        echo "so this procedure can be repeated, without reassessing all anew."
        cat .$scrg2_base-0
        echo "(cat .$scrg2_base-0)"
        echo "\$part_001_001M: $part_001_001M"
        echo "\$parts_start: $parts_start"
        if [ "$part_001_001_initial" != "y" ]; then
            ask "echo new value to .$scrg2_base-0?"
            if [ "$?" == 0 ]; then
                echo "Pls. type the equivalent of NNm:NNs.NNNms value to echo to .$scrg2_base-0"
                read new_scrg2_base_0
                echo $new_scrg2_base_0 > .$scrg2_base-0
                cat .$scrg2_base-0
                echo "(cat .$scrg2_base-0)"
            fi
        fi
    else
        unset part_001_001_initial
    fi
done
