#!/bin/bash
#This script will read from tmp.txt and output a count of each letter.  It will ignore newlines and spaces.  
tr -d '\n' <  tmp.txt| tr -d ' ' |sed 's/\(.\)/\1\n/g' |sort |uniq -c |sort -gr
