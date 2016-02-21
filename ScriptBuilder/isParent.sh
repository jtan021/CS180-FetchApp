#!/bin/sh
#
# Course: CS 100 Summer Session II 2015
# First Name: Jonathan
# Last Name: Tan
# Username: jtan021
# Email Address: jtan021@ucr.edu
# SID: 861108230
#
# AssignmentID (e.g. lab0, lab1, ..., hw0, hw1, ...): HW3
# Filename: isBaseClass.sh
#
# I hereby certify that the contents of this file represent
# my own original individual work. Nowhere herein is there
# code from any outside resources such as another individual,
# a website, or publishings unless specifically designated as 
# permissible by the instructor or TA.
# I also understand that by cheating, stealing, plagiarism or 
# any other form of academic misconduct defined at
# http://conduct.ucr.edu/policies/academicintegrity.html,
# the consequences will be an F in the class, and additional
# disciplinary sanctions, such as the dismissal from UCR.
#
#
# Name: isParent.sh	
# Input: InheritanceTree.txt <$1>
# 	 Class Name <$2>
# Output: 1 if class is a base class
#	 -1 if class is not
# Note:  
#
#

if [ $# -ne 2 ]; then
	echo -e "Usage: $0 <InheritanceTree.txt> <Class Name>"
	exit
fi

while read line
do
	curr_Parents=`echo "$line" | cut -d ' ' -f2`
	if [ "$curr_Parents" = "$2" ]; then
		echo "1"
		exit
	fi
	totalDelim=$(grep -o ":" <<< "$curr_Parents" | wc -l)
	totalDelim=$[$totalDelim +1]
	count=1;
	while [ $count -le $totalDelim ]
	do
		curr_base=`echo "$curr_Parents" | cut -d ':' -f$count`
		#echo -e "$curr_base"
		if [ "$curr_base" = "$2" ]; then
			echo "1"
			exit
		fi
		count=$[$count +1]
	done	
done < $1

echo "-1"

