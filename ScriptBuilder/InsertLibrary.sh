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
# Name:	InsertLibrary.sh
# Input: listlibraries.txt <$1>
# 	 Library Name <$2>
# Output: 
# Note: If library name is not present, it will append the library name at the end of $1
#	If library name is 0, terminate
#
#

if [ $# -ne 2 ]; then
	echo "Usage: $0 <listlibraries.txt> <Library Name>"
	exit
fi

if [ "$2" = "0" ]; then
	exit
fi

while read line
do
	if [ "$line" == "$2" ]; then
		exit
	fi
done < $1

echo "$2" >> $1
