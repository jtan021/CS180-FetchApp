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
# Name: InitClassFiles.sh	
# Input: Class Name <$1>, First Class Member Name <$2>, Second Class Member Name <$3>
# 		
# Output: Creates the source and header files for the class
# Note:  
#
#
if [ $# -lt 1 ]; then
	echo "Usage: $0 <Class Name> <Member1:Type> <Member2:Type> ..."
	exit	
fi

Class=$1
./AddHeader.sh $Class.hh
./AddHeader.sh $Class.cc
echo "#ifndef ${Class}_hh\n#define ${Class}_hh\n" >> $Class.hh

#Comment Headers
echo "//************************************************************\n// Class Name: $Class\n//\n// Design:\n//\n// Usage/Limitations:\n//\n//*************************************************************\n" >> $Class.hh
echo "//************************************************************\n// $Class Implementation\n//************************************************************\n" >> $Class.cc

#Temporary Library
touch templibrary12345.txt

#Checks and generates libraries
for param in "$@"
do
	if [ "$param" != "$Class" ]; then
		ParamKey=`./getSuffix.sh $param`
		Library=`./getLibrary.sh Types.table $ParamKey`
		./InsertLibrary.sh listlibraries.txt "$Library"
		./InsertLibrary.sh templibrary12345.txt "$Library"
	fi
done

#Echos library names to .CC
while read line
do			
		echo "#include $line" >> $Class.cc
		echo "#include $line" >> $Class.hh
done < templibrary12345.txt 

./AddConsDes.sh InheritanceTree.txt "$Class"

echo "" >> $Class.cc
echo "" >> $Class.hh

#Remove Temporary Library
rm templibrary12345.txt

#Creates Accessors/Mutators in .HH and .CC files
for var in "$@"
do
	if [ "$var" != "$1" ]; then
		VarName=`./getPrefix.sh $var`
		VarKey=`./getSuffix.sh $var`
		VarType=`./getValue.sh Types.table $VarKey`
	#	echo "$VarName\n$VarKey\n$VarType\n"
		./AddGetSetHeader.sh "$VarType" "$VarName" "$Class.hh"
		./AddGetSetSource.sh "$VarType" "$VarName" "$Class" "$Class.cc"
	fi	
done

#Private/Protected variables for .HH
FoundClass=0
if [ `./isParent.sh "InheritanceTree.txt" "$Class"` == "1" ]; then
	FoundClass=$[$FoundClass +1]
fi

if [ $FoundClass -gt 0 ]; then
	echo "\tprotected:" >> $Class.hh
else
	echo "\tprivate:" >> $Class.hh
fi

for private_var in "$@"
do
	if [ "$private_var" != "$1" ]; then
		Priv_Name=`./getPrefix.sh $private_var`
		Priv_Key=`./getSuffix.sh $private_var`
		Priv_Type=`./getValue.sh Types.table $Priv_Key`
		echo "\t$Priv_Type m_$Priv_Name;" >> $Class.hh
	fi
done

echo "};\n\n#endif" >> $Class.hh
 
