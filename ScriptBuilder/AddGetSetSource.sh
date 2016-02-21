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
# Name: AddGetSource.sh 	
# Input: C++ Type <$1>
# 	 Class Member Name <$2>
#	 Class Name <$3>
#	 Filename <$4>
# Output: 
# Note: Appends to the end of the source file the Get/Set method codes related to the passed in parameters
#
#
if [ $# -ne 4 ]; then
	echo "Usage: $0 <C++ Data type> <Class Member> <Class> <File>"
	exit
fi

Type=$1
Member=$2
Class=$3

echo "// Accessor of $Member\n$Type $Class::Get$Member() const\n{\n\treturn m_$Member;\n}\n" >> $4
echo "// Mutator of $Member\nvoid $Class::Set$Member($Type& value)\n{\n\tm_$Member = value;\n}\n" >> $4



