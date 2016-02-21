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
# Filename: AddConsDes.sh
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
# Name: AddConsDes.sh
# Input: InheritanceTree.txt <$1>
#	 Class Name <$2>
# 		
# Output: Creates the class code handling multiple inheritance and appends it to the end of $2.hh and $2.cc
# Note: 
#
#

if [ $# -ne 2 ]; then
	echo -e "Usage: $0 <InheritanceTree.txt> <Class Name>"
	exit
fi

if [ ! "$1" = "InheritanceTree.txt" ]; then
	echo -e "Usage: $0 <InheritanceTree.txt> <Class Name>"
	exit
fi

Class=$2

while read line
do
	DerClass=`echo "$line" | cut -d ' ' -f1`
	#echo -e "$DerClass"
	if [ "$Class" = "$DerClass" ]; then
		BaseClass=`./getParents.sh InheritanceTree.txt "$Class"`
		#echo -e "$BaseClass"
		Parents=""
		Constructor=""

		#Get name of last base class
		for last in $BaseClass; do :; done

		#For each Base Class, append it to Parents and Constructor string
		#Parent string is to be appended at the end of the class declaration 
		#Constructor string is to be appended at the end of the Constructor
		for var in $BaseClass	
		do
			if [ "$var" == "$last" ]; then
				Parents=$Parents"public $var"
				Constructor=$Constructor"$var()"
			else
				Parents=$Parents"public $var, "
				Constructor=$Constructor"$var(), "
			fi
			#Echo Base Libraries to Class.hh/.cc
			BaseLibrary=`./getLibrary.sh Types.table "$var"`
			#echo -e "$BaseLibrary"
			echo "#include $BaseLibrary" >> $Class.hh
			echo "#include $BaseLibrary" >> $Class.cc
		done

		DerLibrary=`./getLibrary.sh Types.table "$DerClass"`
		echo "#include $DerLibrary" >> $Class.cc
		echo -ne "\nclass $DerClass: " >> $Class.hh
		echo "$Parents" >> $Class.hh
		echo "{\n\tpublic:\n\t$DerClass();\n\t~$DerClass();" >> $Class.hh
		echo "\n// $DerClass Constructor\n$DerClass::$DerClass():$Constructor\n{}\n\n// $DerClass Destructor\n$DerClass::~$DerClass()\n{}" >> $Class.cc
		exit
	fi
done < $1

#echo -e "Hello!"
echo "\nclass $Class\n{\n\tpublic:\n\t$Class();\n\tvirtual ~$Class();" >> $Class.hh
echo "#include \"./$Class.hh\"\n\n// $Class Constructor\n$Class::$Class()\n{}\n\n// $Class Destructor\n$Class::~$Class()\n{}" >> $Class.cc


