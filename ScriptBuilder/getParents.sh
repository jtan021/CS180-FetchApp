#!/bin/sh
#
# Course: CS 100 Summer Session II 2015
# First Name: Jonathan
# Last Name: Tan
# Username: jtan021
# Email Address: jtan021@ucr.edu
# SID: 861108230
#
# AssignmentID (e.g. lab0, lab1, ..., hw0, hw1, ...): HW0
# Filename:
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
# Name: getLibrary.sh
# Input: InheritanceTree.txt <$1>
# 	 Class Name <$2>
# Output: Output the names of the passed in parameter's base classes
#	  If the passed in class has no parents, return -1
# Note:  
#
#

if [ $# -ne 2 ]; then
	echo -e "Usage: $0 <InheritanceTree.txt> <Class Name>"
	exit
fi

string=""
while read line
do
	curr=`echo "$line" | cut -d ' ' -f1`
	curr_Parents=`echo "$line" | cut -d ' ' -f2`
	if [ $2 == $curr ]; then
		totalDelim=$(grep -o ":" <<< "$curr_Parents" | wc -l)
		if [ ! $totalDelim -ge 1 ]; then
			exit
		fi 
		totalDelim=$[$totalDelim +1]
		count=1;
		while [ $count -le $totalDelim ]
		do
			curr_base=`echo "$curr_Parents" | cut -d ':' -f$count`
			string=$string"$curr_base "
			count=$[$count +1]
		done	
		echo -e "$string"
		exit
	fi
done < $1

echo "-1"

