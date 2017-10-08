#!/bin/bash

echo just the idea here. Incompleted.
read FAKE

function ask()	# this function borrowed from "Advanced BASH Scripting Guide"
				# (a free book) by Mendel Cooper
{
    echo -n "$@" '[y/[n]] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

if [ $# -eq 0 ]; then
    echo give the file to apply text wrapping to
    exit 0
fi


logs_section=$1

numlines=$(cat $logs_section | sed -n $=);
echo \$numlines: $numlines
#read FAKE

#echo cat $logs_section \| grep uncenz-1st \' 
#cat $logs_section | grep uncenz-1st 
#read FAKE

num1stlines=$(cat $logs_section | grep uncenz-1st | sed -n $=);
echo \$num1stlines: $num1stlines
#read FAKE

for line in $(cat $logs_section | seq $numlines); do
    echo $line
    echo sed -n "${line}p"
    #sed -n "${line}p" $logs_section | sed '/.*uncenz-1st.*/Q' | sed 's/ / \n/g'
    #read FAKE
    #line_arr=$(sed -n "${line}p" $logs_section | sed '/.*uncenz-1st.*/Q' \
    #    | sed 's/ / \n/g')
    #read FAKE
    #sed -n "${line}p" $logs_section | sed 's/ / \n/g'
    sed -n "${line}p" $logs_section | sed 's/ / \n/g' > line${line}
    ls -l line${line}
    echo cat line${line} ?
    #ask
    #if [ "$?" == 0 ]; then
    #    cat line${line}
    #fi
   #read FAKE
    line_arr=($(cat line${line}))
    echo "echo \${line_arr[@]}"
   #read FAKE
    echo ${line_arr[@]} 
   #read FAKE
    echo "echo \${#line_arr[@]}"
   #read FAKE
    echo ${#line_arr[@]}
   #read FAKE
    for word in $(seq 0 $((${#line_arr[@]} -1 ))); do
        echo -n "$word: ${line_arr[$word]}"
    done
    > words
    > words_prev
    > words_TMP
    > ${line}_wrapped
    order_of_word="0"
    echo \$order_of_word: $order_of_word
    ls -l words words_prev words_TMP ${line}_wrapped
   #read FAKE
    for word in $(seq 0 $((${#line_arr[@]} -1 ))); do
        echo \$word: $word
        echo \$word_prev: $word_prev
        cp -av words words_prev
        echo -n "${line_arr[$word]} " >> words
       #read FAKE
        cat words | wc -c
        wc_c_words=$(cat words | wc -c)
       #read FAKE
        echo \$wc_c_words: $wc_c_words
        echo \$word: $word
       #read FAKE
        if [ "$wc_c_words" -gt "79" ]; then
            echo "" >> words_prev
            cat words_prev
            cat words_prev >> ${line}_wrapped
           #read FAKE
            echo \$word: $word
            order_of_word=$word
            echo \$order_of_word: $order_of_word
           #read FAKE
            echo -n "${line_arr[$word]} " > words_TMP
            cat  words_TMP > words
            > words_TMP
            continue
        fi
        if [ "$word" == "$((${#line_arr[@]} -1 ))" ]; then
            #echo -n "${line_arr[$word]} " > words_TMP
            #cat  words_TMP > words_prev
            #> words_TMP
            #echo "" >> words_prev
            #cat words_prev
            echo "" >> words
            cat words >> ${line}_wrapped
            > words
            order_of_word=$word
            echo \$order_of_word: $order_of_word
           #read FAKE
        fi
    done
done
