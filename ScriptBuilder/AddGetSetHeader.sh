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
# Name: AddGetSetHeader.sh	
# Input: Data Type <$1>, Class Member <$2>, File <$3>
# 		
# Output: Add 4 lines of code related to the Get/Set given passed parameters
# Note:  
#
#

if [ $# -ne 3 ]; then
	echo "Usage: $0 <C++ Data Type> <Class Member> <File>"
	exit
fi

Type=$1
Member=$2
echo "\t//Accessor/Mutator of m_$Member\n\t$Type Get$Member() const;\n\tvoid Set$Member($Type& value);\n" >> $3
