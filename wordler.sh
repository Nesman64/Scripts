#!/bin/bash
#Original command might look like this:
# grep '^.....$' /usr/share/dict/american-english |grep -v [^a-z]  |grep e | grep n | grep -v ..e.. |grep -v ....e |grep -v ...n. |grep -vc [arosbld]
maxguesses=6
turn=0
dictionary="/usr/share/dict/american-english"

#Higher debug level triggers more test output
debug=0

#Check if guesses have been supplied as arguments
if [ $# = 0 ] ;then
	inputdone=0
	i=0
	echo "Enter your guesses, one at a time.  Press Enter after each.  Press Enter again when done."
	while [ $inputdone -ne 1 ]; do
		read
		if [ -z $REPLY ]; then 
			inputdone=1
		else
			temp=($(echo $REPLY | tr '[:upper:]' '[:lower:]' |grep -v [^a-z]))
			if [ ${#temp} = 5 ]; then
				guess[$i]=$temp
			else
				echo "Each guess must be 5 letters.  Try again."
				exit
			fi
		
		
			i=$(( $i + 1 ))
			turn=$(( $turn + 1 ))
		fi
	done
	
fi

#Store supplied guesses as variable array
#TODO Make sure each guess is 5 letters, no non-letter chars.  

i=0
while [ $# -gt 0 ]; do
#	if [ ${#1} = 5 ]; then
	temp=($(echo $1 | tr '[:upper:]' '[:lower:]' |grep -v [^a-z]))
	if [ ${#temp} = 5 ]; then
		guess[$i]=$temp
		if [ $debug -gt 1 ]; then
			echo Guess $i: ${guess[$i]}
		fi
		i=$(( $i + 1 ))
		turn=$(( $turn + 1 ))
		shift	
	else
		echo "Each guess must be 5 letters.  Try again."
		exit
	fi
done

if [ $debug -gt 0 ]; then
	echo Guesses: ${guess[@]}
	echo Turn: $turn
fi

if [ $debug -gt 4 ]; then
	row=0
	col=0
	echo ${guess[$row]:$col:1}
fi

#Get the list of Yellow letters.  
yellow=""
green=""
echo "Enter any Yellow letters, without spaces and press Enter. (Note: Don't include Yellow letters that have turned Green unless they also appear Yellow in the same guess)"
read yellow

if [ ${#yellow} = 0 ]; then 
	yellow="."
fi

if [ $debug -gt 0 ]; then
	echo Yellow: $yellow
fi


echo "Enter any Green letters, using periods in place of missing letters and press Enter.  If no Green letters have been found, just press Enter."
read green

#If input was blank, set Green to all periods
if [ ${#green} = 0 ]; then 
	green="....."
fi

while [ ${#green} -ne 5 ]; do
	echo "Please enter 5 characters, using periods for missing letters.  examples: ..... or th..k or ..in." 
	read green
done


if [ $debug -gt 0 ]; then
	echo Green: $green
fi

grepcommand='grep '^$green\$  $dictionary'  |grep -v [^a-z] '

#loop through yellow, one letter at a time, adding grep calls for Yellow letters
for ((i = 0 ; i < ${#yellow} ; i++)); do 
	grepcommand+='| grep '${yellow:$i:1}'' 
done

#Collect first, second, etc letter from each guess.
position=""
for ((i = 0 ; i < 5 ; i++)); do 
	for count in ${!guess[@]}; do
		position[$i]+=${guess[$count]:$i:1}
	done
done

#Check (visually) that each element in $position is a column of letters from guesses
if [ $debug -gt 1 ]; then
	echo Position of each letter: 
		for index in ${!position[@]}; do
			echo ${position[$index]}
		done
fi

#Compare positions of Yellow letters in guesses and add grep -v calls for them
#5 passes, 5 array elements
#Use sed to delete any non-yellow chars, like this
#$echo test | sed 's/[^se]//g'
#es

for ((i = 0 ; i < 5 ; i++)); do 
	temp=($(echo ${position[$i]} | sed 's/[^'$yellow']//g'))
	eliminated[$i]=$temp
done

#Create prefix/postfix periods to go around eliminated letters
pre[0]=""
for ((i = 1 ; i < 5 ; i++)); do 
	pre[$i]=${pre[$(($i - 1))]}"."
done


for ((i = 0 ; i < 4 ; i++)); do 
	post[$i]=${pre[$((4 - $i))]} 
done

#Combine pre/eliminated/post into grep -v calls
for ((i = 0 ; i < 5 ; i++)); do 
	if [ ${#eliminated[$i]} -gt 0 ]; then
		grepcommand+='|grep -v '${pre[$i]}[${eliminated[$i]}]${post[$i]}' '
	fi
done

#TODO Figure out if it matters if the user inputs a Yellow letter that became Green in a later guess



#Clobber all of the guessed letters into a single variable
allletters=
for count in ${!guess[@]}; do
	allletters+=${guess[$count]}; 
done

#work out which letters are grey and grep -v them
grey=($(echo $allletters |tr -d "$green" | tr -d "$yellow"))

if [ $debug -gt 0 ]; then
	echo Grey: $grey

fi
grepcommand+='|grep -v ['$grey'] ' 

#Final grep.  Adding -c at the end returns a count of words instead of the list.
grepcommand+='|grep -c . '

if [ $debug -gt 1 ]; then
	echo Grep: $grepcommand
fi

echo -n "Possible words remaining: "
eval $grepcommand

exit
#list guesses
echo ${guess[@]}
#count guesses
echo ${#guess[@]}
#echo the letter in position $i of guess 0
echo ${guess[0]:$i:1}
