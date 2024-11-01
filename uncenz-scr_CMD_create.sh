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

echo ". uncenz-setup from ${0##*/}"
. uncenz-setup

function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function cat_ls_file () {
    if [ -e "$1" ]; then
        cat $1
        ls -l $1
        echo "(cat/ls -l $1)"
        read NOP
    else
        echo "$1 non extant"; echo 
    fi
}

if [ -n "$1" ]; then
    scr_file="$1"
    echo \$scr_file: $scr_file
    ext=${scr_file##*.}
    if ( echo $scr_file | grep '\.webm$' ); then
        scr=${scr_file%*.webm}
    fi
    if ( echo $scr_file | grep '\.mkv$' ); then
        scr=${scr_file%*.mkv}
    fi
    scr_file=$scr.$ext
    ls -l $scr.$ext
    echo "(ls -l \$scr.\$ext)"
else
    if [ ! -e "$scr.$ext" ]; then 
        ls -l $scr.$ext
        echo "and it must exist"
        echo "sleep 5 and exit 1"; sleep 5
        exit 1
    fi
fi

if [ -n "$2" ]; then
    parts_start="$2"
else
    parts_start=$(<.$scr-g2-0)
    if [ "X\${parts_start}X" ==  "XX" ]; then
        echo "can not proceed, $parts_start is empty"
        echo "X\${parts_start}X: X${parts_start}X"
        echo "(you see ... XX, i.e. \${parts_start} is empty string)"
        echo "sleep 5 and exit 1"; sleep 5
        exit 1
    else
        echo \$parts_start: $parts_start
    fi
fi
read NOP

if [ -e ".$scr-g2.CMD" ]; then
    cat_ls_file .$scr-g2.CMD
    ask "truncate .$scr-g2.CMD ?"
    if [ "$?" == 0 ]; then
        > .$scr-g2.CMD
    fi
fi

unset part_001_001_ok
part_001_001_initial=y
while [ "$part_001_001_ok" != "y" ]; do
    if [ "$part_001_001_initial" != "y" ]; then
        parts_start=$(<.$scr-g2-0)
        while [ ! -n "$parts_start" ] || [ "X$parts_start" == "X" ]; do
            echo "Pls. type the equivalent of Nm:NNs.NNNms value to echo to .$scr-g2-0"
            read parts_start
            echo $parts_start > .$scr-g2-0
            cat_ls_file .$scr-g2-0
        done
    fi
    if [ "$parts_start" != "0:00.000" ]; then
        echo \$parts_start: $parts_start
        echo "mkvmerge -q -o ${scr}_.$ext --split timecodes:$parts_start ${scr}.$ext" |& tee -a .$scr-g2.CMD
        mkvmerge -q -o ${scr}_.$ext --split timecodes:$parts_start ${scr}.$ext
        echo "ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext" |& tee -a .$scr-g2.CMD
        ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext
        part_001=$(ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001.$ext)
        echo "# \$part_001: $part_001" >> .$scr-g2.CMD
        part_001M=$(echo $part_001*1000/1|bc)
        echo "# \$part_001M: $part_001M" |& tee -a .$scr-g2.CMD
        read NOP
        echo \$parts_start: $parts_start
        parts_start_min=$(echo $parts_start | awk -F: '{print $1}')
        parts_start_sec=$(echo $parts_start | awk -F: '{print $2}'| awk -F. '{print $1}')
        parts_start_msec=$(echo $parts_start | awk -F. '{print $2}')
        echo \$parts_start_min: $parts_start_min
        echo \$parts_start_sec: $parts_start_sec
        echo \$parts_start_msec: $parts_start_msec
        parts_startM=$(echo "(($parts_start_min*60+$parts_start_sec)*1000+$parts_start_msec)/1"|bc)
        echo "# \$parts_startM: $parts_startM" |& tee -a .$scr-g2.CMD
        read NOP
        ask "Try with these values?"
        if [ "$?" == 0 ]; then
            if [ "$ext" == "mkv" ]; then
                echo "Running:"
                echo "ffmpeg -y -i ${scr}_-001.$ext -c:v hevc -g 2 ${scr}_-001-g2.$ext &> /dev/null" |& tee -a .$scr-g2.CMD
                echo "echo \"Will notify when ${scr}_-001-g2.$ext is created\"" |& tee -a .$scr-g2.CMD
                ffmpeg -y -i ${scr}_-001.$ext -c:v hevc -g 2 ${scr}_-001-g2.$ext &> /dev/null
                echo "ls -l ${scr}_-001-g2.$ext" >> .$scr-g2.CMD
                ls -l ${scr}_-001-g2.$ext
            fi
            if [ "$ext" == "webm" ]; then
                echo "Running:"
                echo "ffmpeg -y -i ${scr}_-001.$ext -c:v libvpx-vp9 -row-mt 1 -crf 55 -g 2 ${scr}_-001-g2.$ext &> /dev/null" |& tee -a .$scr-g2.CMD
                echo "echo \"Will notify when ${scr}_-001-g2.$ext is created\"" |& tee -a .$scr-g2.CMD
                ffmpeg -y -i ${scr}_-001.$ext -c:v libvpx-vp9 -row-mt 1 -crf 55 -g 2 ${scr}_-001-g2.$ext &> /dev/null
                echo "ls -l ${scr}_-001-g2.$ext" >> .$scr-g2.CMD
                ls -l ${scr}_-001-g2.$ext
            fi
            echo "mkvmerge -q -o ${scr}_-001-g2_.$ext --split timecodes:$parts_start ${scr}_-001-g2.$ext" |& tee -a .$scr-g2.CMD
            mkvmerge -q -o ${scr}_-001-g2_.$ext --split timecodes:$parts_start ${scr}_-001-g2.$ext
            echo "ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext" |& tee -a .$scr-g2.CMD
            ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext
            part_001_001=$(ffprobe -v 0 -of default=nw=1:nk=1 -show_entries format=duration ${scr}_-001-g2_-001.$ext)
            echo "# \$part_001_001: $part_001_001" |& tee -a .$scr-g2.CMD
            part_001_001M=$(echo $part_001_001*1000/1|bc)
            echo "# \$part_001_001M: $part_001_001M" |& tee -a .$scr-g2.CMD
        else
            echo "user declined to manipulate starting with these:"
            echo "\$parts_start: $parts_start"
            echo "\$parts_startM: $parts_startM"
            echo "\$part_001M: $part_001M"
            echo "So we now \"continue\""
            unset part_001_001_initial
            continue
        fi
    else
       echo "in else, i.e. acceptably synced as captured"
       echo "or old Xorg 800x600 or such captures (NOT TESTED recently)"
        echo \$parts_start: $parts_start
        if [ "$TERM" == "xterm" ]; then
            echo "Running:"
            echo "ffmpeg -i $scr.$ext -map 0:v -c:v libx264 -g 2 $scr-g2.$ext" >> .$scr-g2.CMD
            echo "echo \"Will notify when $scr-g2.$ext is created\"" >> .$scr-g2.CMD
            ffmpeg -i $scr.$ext -map 0:v -c:v libx264 -g 2 $scr-g2.$ext
            echo "ls -l $scr-g2.$ext" >> .$scr-g2.CMD
            ls -l $scr-g2.$ext
            echo "ln -s $scr-g2.$ext $scr-g2_0.$ext" >> .$scr-g2.CMD
            ln -s $scr-g2.$ext $scr-g2_0.$ext
        else
            echo \$TERM: $TERM  # foot
            echo "if [ ! -e "$scr-g2_0.$ext" ]; then ln -s $scr.$ext $scr-g2_0.$ext; fi" >> .$scr-g2.CMD
            if [ ! -e "$scr-g2_0.$ext" ]; then ln -s $scr.$ext $scr-g2_0.$ext; fi
            echo "ls -l $scr.$ext $scr-g2_0.$ext" >> .$scr-g2.CMD
            ls -l $scr.$ext $scr-g2_0.$ext
        fi
        if [ ! -e ".$scr-g2-0" ] || [ ! -s ".$scr-g2-0" ]; then
            echo "$parts_start" > .$scr-g2-0
        else
            parts_start_bis=$(<.$scr-g2-0)
            if [ "$parts_start_bis" == "parts_start" ]; then
                echo -n "\$parts_start value shows .$scr-g2-0 is ok"
            fi
        fi
        cat_ls_file .$scr-g2.CMD
        cat_ls_file .$scr-g2-0
    fi
    ask "ok?"
    if [ "$?" == 0 ]; then
        if [ "$parts_start" == "0:00.000" ]; then
            chmod 755 .$scr-g2.CMD
            exit 0
        else
            part_001_001_ok=y
            if [ -e "${scr}_-001-g2_-002.$ext" ]; then
                echo "mkvmerge -q -o ${scr}-g2_0.$ext ${scr}_-001-g2_-002.$ext + ${scr}_-002.$ext" |& tee -a .$scr-g2.CMD
                mkvmerge -q -o ${scr}-g2_0.$ext ${scr}_-001-g2_-002.$ext + ${scr}_-002.$ext
            # for cases where --split ${scr}_-001-g2.$ext above gets only one file
            else
                mv -iv ${scr}_-002.$ext ${scr}-g2_0.$ext |& tee -a .$scr-g2.CMD
            fi
            mpv --window-scale=0.95 ${scr}-g2_0.$ext
            echo "ls -l ${scr}_-00[12].$ext ${scr}_-001-g2.$ext" >> .$scr-g2.CMD
            ls -l ${scr}_-00[12].$ext ${scr}_-001-g2.$ext
            echo "ls -l ${scr}_-001-g2_-00[12].$ext" >> .$scr-g2.CMD
            ls -l ${scr}_-001-g2_-00[12].$ext
            echo "echo \"All to be removed when you hit Enter\"" |& tee -a .$scr-g2.CMD
            echo "read NOP" |& tee -a .$scr-g2.CMD
            read NOP
            echo "rm -v ${scr}_-00[12].$ext ${scr}_-001-g2.$ext" >> .$scr-g2.CMD
            rm -v ${scr}_-00[12].$ext ${scr}_-001-g2.$ext
            echo "rm -v ${scr}_-001-g2_-00[12].$ext" >> .$scr-g2.CMD
            rm -v ${scr}_-001-g2_-00[12].$ext
            echo "Pls. review/edit the script file:"
            echo "(cat_ls_file .$scr-g2.CMD next)"
            read NOP
            cat_ls_file .$scr-g2.CMD
            echo "so this procedure can be repeated, without reassessing all anew."
            cat_ls_file .$scr-g2-0
            echo "\$part_001_001M: $part_001_001M"
            echo "\$parts_start: $parts_start"
            chmod 755 .$scr-g2.CMD
        fi
    else
        unset part_001_001_initial
        ask "echo new value to .$scr-g2-0?"
        if [ "$?" == 0 ]; then
            echo "Pls. type the equivalent of Nm:NNs.NNNms value to echo to .$scr-g2-0"
            read parts_start
            echo $parts_start > .$scr-g2-0
            cat_ls_file .$scr-g2-0
        fi
        ask "truncate .$scr-g2.CMD ?"
        if [ "$?" == 0 ]; then
            > .$scr-g2.CMD
        fi
    fi
done
echo "This:"
ls -l ${scr}-g2_0.$ext
echo "as well as these:"
cat_ls_file .${scr}-g2-0
cat_ls_file .${scr}-g2.CMD
echo "might be fine."
