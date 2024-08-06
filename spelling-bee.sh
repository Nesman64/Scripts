#!/bin/bash
if [ -z $1 ]
then
        echo "This script takes a string of letters as an argument and then counts how many words can be made using only those letters.  Start the string with the central letter, which is required in all words."
        exit
fi

string=$1
key=${string:0:1}
wordlist=($(grep $key /usr/share/dict/american-english | grep -v [A-Z] | grep -v [^$string]|awk '{ print length, $0 }' | sort -n -s -r | cut -d' ' -f2-))


echo "Word count:  ${#wordlist[@]}"
echo "Most chars:  ${#wordlist[0]}"
if [[ $2 == "cheat" ]]
then
        echo "${wordlist[@]:0:10}"
fi
