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
# Name:	InsertInheritance.sh
# Input: InheritanceTree.txt <$1>
# 	 Derived Class <$2>
#	 Base Class <$3>
#	 Base Class <$4,5,6...>
#	
# Output: 
# Note: add Derived Class and its Base Classes to InheritanceTree.txt
#	
#
#

if [ $# -lt 3 ]; then
	echo "Error: Must provide at least 3 parameters."
	echo "Usage: $0 <InheritanceTree.txt> <Derived Class> <Base Class> <Base Class>.."
	exit
fi

#Check if Class already exists as a derived class in InheritanceTree.txt
while read line
do
	curr=`echo "$line" | cut -d ' ' -f1`
	#echo -e "$curr"
	if [ "$line" = "$2" ]; then
		exit
	fi
done < $1

string="$2 "

for last in $@; do :; done

for var in "$@"
do
	if [ "$var" != "$1" ] && [ "$var" != "$2" ] && [ "$var" != "0" ]; then
		if [ "$var" = "$last" ]; then
			string=$string"$var"
		else
			string=$string"$var:"
		fi
	fi
done

echo "$string" >> $1

