#!/bin/sh
#
# Course: CS 100 Summer Session II 2015
# First Name: Jonathan
# Last Name: Tan
# Username: jtan021
# Email Address: jtan021@ucr.edu
# SID: 861108230
#
# AssignmentID (e.g. lab0, lab1, ..., hw0, hw1, ...): HW1
# Filename: AddMethod.sh
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
# Name:	AddMethod.sh
# Input: Class Name <$1>
# 	 MethodName <$2>
#	 Value <$3>
#	 Type <$4>
#	 Param.... <$5, $6, ...>
# Output: Inserts the method definition before the definition of class members in *.hh
# 	  Appends mmember functions to end of *.hh  
# Note:  
#
#
error="Usage: $0 <Class Name> <Method Name> <constant/non-constant> <Type> <Param1>:<Type1> <Param2>:<Type2>...."
if [ $# -lt 3 ]; then
	echo -e "$error"
	exit
fi

Class="$1"
Method="$2"
Cons="$3"
CType="$4"
Param1=`./getSuffix.sh "$5"`
Num=1
Type=`./getValue.sh Types.table "$CType"`

function VoidType {
	#Create temp library
	touch templibrary1234567.txt
	#Gather library files
	for param in "$@"
	do
		if [[ "$param" = *:* ]]; then
			ParamKey=`./getSuffix.sh "$param"`
			Library=`./getLibrary.sh Types.table "$ParamKey"`
			./InsertLibrary.sh templibrary1234567.txt "$Library"
		fi
	done		
	#Insert Appropriate Libraries
	AddedLibHH=0
	AddedLibCC=0
#	HHLibraryString=""
#	CCLibraryString=""
	while read line
	do
		if ! grep -Fxq "#include $line" $Class.hh ; then
			sed -i -e "/class $Class/i \#include $line" $Class.hh
#			HHLibraryString="$HHLibraryString#include $line\n"
			AddedLibHH=$[$AddedLibHH +1]
		fi
		if ! grep -Fxq "#include $line" $Class.cc ; then
			sed -i -e "/$Class Constructor/i \#include $line" $Class.cc
#			CCLibraryString="$CCLibraryString#include $line\n"
			AddedLibCC=$[$AddedLibCC +1]
		fi
	done < templibrary1234567.txt
	if [ $AddedLibHH -gt 0 ]; then
#		sed -i -e "/class $Class/i \\$HHLibraryString" $Class.hh
		sed -i -e "/class $Class/i \ " $Class.hh
	fi
	if [ $AddedLibCC -gt 0 ]; then
#		sed -i -e "/$Class Constructor/i \\$CCLibraryString" $Class.cc
		sed -i -e "/$Class Constructor/i \ " $Class.cc
	fi
	#Delete temp library
	rm templibrary1234567.txt

	#Output comments to Class.hh for Void
	if [ "$Param1" != "" ]; then
		PassedParam="// Method:\t$Method\n\t// Output:\tValueless,\n\t// Input:\t$Param1,"
	else
		PassedParam="// Method:\t$Method\n\t// Output:\tValueless,\n\t// Input:\tValueless,"
	fi
#	ParamCount=1
	for param in "$@"
	do
		if [[ "$param" = *:* ]] && [ "$param" != "$5" ]; then
			ParamName=`./getSuffix.sh "$param"`
			PassedParam="$PassedParam\n\t//\t\t$ParamName,"
#			if [ $ParamCount -lt $# ]; then
#				PassedParam="$PassedParam,"
#			fi
		fi
#		ParamCount=$[$ParamCount +1]
	done

	if [ "$Cons" = "constant" ]; then
		#To Class.HH
		ParamString="\n\tvoid $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString) const;"
		PassedParam="$PassedParam $ParamString"
		sed -i -e "/private:/i \	\\$PassedParam\n" $Class.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $Class.hh

		#To Class.CC
#		echo -e " \n" >> $Class.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $Class.cc
		echo -ne "void $Class::$Method(" >> $Class.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $Class.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $Class.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ") const\n{}\n\n" >> $Class.cc

	elif [ "$Cons" = "non-constant" ]; then
		#To Class.HH
		ParamString="\n\tvoid $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString);"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $Class.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $Class.hh

		#To Class.CC
		echo -e " \n" >> $Class.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $Class.cc
		echo -ne "void $Class::$Method(" >> $Class.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $Class.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $Class.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ")\n{}\n\n" >> $Class.cc 
	else
		echo -e "$error"
	fi
}

function VirtualVoidType {
	ParentClass=`./getPrefixACD.sh $1`
	#echo -e "$ParentClass"
	#Create temp library
	touch templibrary1234567.txt
	#Gather library files
	for param in "$@"
	do
		if [[ "$param" = *:* ]]; then
			ParamKey=`./getSuffix.sh "$param"`
			Library=`./getLibrary.sh Types.table "$ParamKey"`
			./InsertLibrary.sh templibrary1234567.txt "$Library"
		fi
	done		
	#Insert Appropriate Libraries
	AddedLibHH=0
	AddedLibCC=0
#	HHLibraryString=""
#	CCLibraryString=""
	while read line
	do
		if ! grep -Fxq "#include $line" $ParentClass.hh ; then
			sed -i -e "/class $ParentClass/i \#include $line" $ParentClass.hh
#			HHLibraryString="$HHLibraryString#include $line\n"
			AddedLibHH=$[$AddedLibHH +1]
		fi
		if ! grep -Fxq "#include $line" $ParentClass.cc ; then
			sed -i -e "/$ParentClass Constructor/i \#include $line" $ParentClass.cc
#			CCLibraryString="$CCLibraryString#include $line\n"
			AddedLibCC=$[$AddedLibCC +1]
		fi
	done < templibrary1234567.txt
	if [ $AddedLibHH -gt 0 ]; then
#		sed -i -e "/class $ParentClass/i \\$HHLibraryString" $ParentClass.hh
		sed -i -e "/class $ParentClass/i \ " $ParentClass.hh
	fi
	if [ $AddedLibCC -gt 0 ]; then
#		sed -i -e "/$ParentClass Constructor/i \\$CCLibraryString" $ParentClass.cc
		sed -i -e "/$ParentClass Constructor/i \ " $ParentClass.cc
	fi
	#Delete temp library
	rm templibrary1234567.txt

	#Output comments to Class.hh for Void
	if [ "$Param1" != "" ]; then
		PassedParam="// Method:\t$Method\n\t// Output:\tValueless,\n\t// Input:\t$Param1,"
	else
		PassedParam="// Method:\t$Method\n\t// Output:\tValueless,\n\t// Input:\tValueless,"
	fi
#	ParamCount=1
	for param in "$@"
	do
		if [[ "$param" = *:* ]] && [ "$param" != "$5" ]; then
			ParamName=`./getSuffix.sh "$param"`
			PassedParam="$PassedParam\n\t//\t\t$ParamName,"
#			if [ $ParamCount -lt $# ]; then
#				PassedParam="$PassedParam,"
#			fi
		fi
#		ParamCount=$[$ParamCount +1]
	done

	if [ "$Cons" = "constant" ]; then
		#To Class.HH
		ParamString="\n\tvirtual void $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString) const;"
		PassedParam="$PassedParam $ParamString"
		sed -i -e "/private:/i \	\\$PassedParam\n" $ParentClass.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $ParentClass.hh

		#To Class.CC
#		echo -e " \n" >> $ParentClass.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $ParentClass.cc
		echo -ne "void $ParentClass::$Method(" >> $ParentClass.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $ParentClass.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $ParentClass.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ") const\n{}\n\n" >> $ParentClass.cc

	elif [ "$Cons" = "non-constant" ]; then
		#To Class.HH
		ParamString="\n\tvirtual void $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString);"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $ParentClass.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $ParentClass.hh

		#To Class.CC
		echo -e " \n" >> $ParentClass.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $ParentClass.cc
		echo -ne "void $ParentClass::$Method(" >> $ParentClass.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $ParentClass.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $ParentClass.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ")\n{}\n\n" >> $ParentClass.cc 
	else
		echo -e "$error"
	fi
}

function ValidType {
	#Create temp library
	touch templibrary1234567.txt
	#Gather library files
	for param in "$@"
	do
		if [[ "$param" = *:* ]]; then
			ParamKey=`./getSuffix.sh "$param"`
			Library=`./getLibrary.sh Types.table "$ParamKey"`
			./InsertLibrary.sh templibrary1234567.txt "$Library"
		fi
	done		
	#Insert Appropriate Libraries 
	AddedLibHH=0
	AddedLibCC=0
	while read line
	do
		if ! grep -Fxq "#include $line" $Class.hh ; then
			sed -i -e "/class $Class/i \#include $line" $Class.hh
			AddedLibHH=$[$AddedLibHH +1]
		fi
		if ! grep -Fxq "#include $line" $Class.cc ; then
			sed -i -e "/$Class Constructor/i \#include $line" $Class.cc
			AddedLibCC=$[$AddedLibCC +1]
		fi
	done < templibrary1234567.txt
	if [ $AddedLibHH -gt 0 ]; then
		sed -i -e "/class $Class/i \ " $Class.hh
	fi
	if [ $AddedLibCC -gt 0 ]; then
		sed -i -e "/$Class Constructor/i \ " $Class.cc
	fi
	#Delete temp library
	rm templibrary1234567.txt

	#Output comments to Class.hh for Valid type
	if [ "$Param1" != "" ]; then
		PassedParam="// Method:\t$Method\n\t// Output:\t$CType,\n\t// Input:\t$Param1,"
	else
		PassedParam="// Method:\t$Method\n\t// Output:\t$CType,\n\t// Input:\tValueless,"
	fi

#	ParamCount=1
	for param in "$@"
	do
		if [[ "$param" = *:* ]] && [ "$param" != "$5" ]; then
			ParamName=`./getSuffix.sh "$param"`
			PassedParam="$PassedParam\n\t//\t\t$ParamName,"
#			if [ $ParamCount -lt $# ]; then
#				PassedParam="$PassedParam,"
#			fi
		fi
#		ParamCount=$[$ParamCount +1]
	done

	if [ "$Cons" = "constant" ]; then
		#To Class.HH
		ParamString="\n\t$Type $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString) const;"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $Class.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $Class.hh

		#To Class.CC
#		echo -e " \n" >> $Class.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $Class.cc
		echo -ne "$Type $Class::$Method(" >> $Class.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $Class.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $Class.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ") const\n{}\n\n" >> $Class.cc

	elif [ "$Cons" = "non-constant" ]; then
		#To Class.HH
		ParamString="\n\t$Type $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString);"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $Class.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $Class.hh

		#To Class.CC
		echo -e " \n" >> $Class.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $Class.cc
		echo -ne "$Type $Class::$Method(" >> $Class.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $Class.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $Class.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ")\n{}\n\n" >> $Class.cc 
	else
		echo -e "$error"
	fi
}

function VirtualValidType {
	ParentClass=`./getPrefixACD.sh $1`
	#Create temp library
	touch templibrary1234567.txt
	#Gather library files
	for param in "$@"
	do
		if [[ "$param" = *:* ]]; then
			ParamKey=`./getSuffix.sh "$param"`
			Library=`./getLibrary.sh Types.table "$ParamKey"`
			./InsertLibrary.sh templibrary1234567.txt "$Library"
		fi
	done		
	#Insert Appropriate Libraries 
	AddedLibHH=0
	AddedLibCC=0
	while read line
	do
		if ! grep -Fxq "#include $line" $ParentClass.hh ; then
			sed -i -e "/class $ParentClass/i \#include $line" $ParentClass.hh
			AddedLibHH=$[$AddedLibHH +1]
		fi
		if ! grep -Fxq "#include $line" $ParentClass.cc ; then
			sed -i -e "/$ParentClass Constructor/i \#include $line" $ParentClass.cc
			AddedLibCC=$[$AddedLibCC +1]
		fi
	done < templibrary1234567.txt
	if [ $AddedLibHH -gt 0 ]; then
		sed -i -e "/class $ParentClass/i \ " $ParentClass.hh
	fi
	if [ $AddedLibCC -gt 0 ]; then
		sed -i -e "/$ParentClass Constructor/i \ " $ParentClass.cc
	fi
	#Delete temp library
	rm templibrary1234567.txt

	#Output comments to Class.hh for Valid type
	if [ "$Param1" != "" ]; then
		PassedParam="// Method:\t$Method\n\t// Output:\t$CType,\n\t// Input:\t$Param1,"
	else
		PassedParam="// Method:\t$Method\n\t// Output:\t$CType,\n\t// Input:\tValueless,"
	fi

#	ParamCount=1
	for param in "$@"
	do
		if [[ "$param" = *:* ]] && [ "$param" != "$5" ]; then
			ParamName=`./getSuffix.sh "$param"`
			PassedParam="$PassedParam\n\t//\t\t$ParamName,"
#			if [ $ParamCount -lt $# ]; then
#				PassedParam="$PassedParam,"
#			fi
		fi
#		ParamCount=$[$ParamCount +1]
	done

	if [ "$Cons" = "constant" ]; then
		#To Class.HH
		ParamString="\n\tvirtual $Type $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString) const;"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $ParentClass.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $ParentClass.hh

		#To Class.CC
#		echo -e " \n" >> $ParentClass.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $ParentClass.cc
		echo -ne "$Type $ParentClass::$Method(" >> $ParentClass.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $ParentClass.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $ParentClass.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ") const\n{}\n\n" >> $ParentClass.cc

	elif [ "$Cons" = "non-constant" ]; then
		#To Class.HH
		ParamString="\n\tvirtual $Type $Method("
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					ParamString="$ParamString$ValueType& $ParamName"
					if [ $ParamCount -lt $# ]; then
						ParamString="$ParamString, "
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		ParamString="$ParamString);"
		PassedParam="$PassedParam $ParamString"
		
		sed -i -e "/private:/i \	\\$PassedParam\n" $ParentClass.hh
		sed -i -e "/protected:/i \	\\$PassedParam\n" $ParentClass.hh

		#To Class.CC
		echo -e " \n" >> $ParentClass.cc
		echo -e "// Method: $Method\n//**********************************************************\n// Purpose:\n//\n// Implementation Notes:\n//\n//**********************************************************" >> $ParentClass.cc
		echo -ne "$Type $ParentClass::$Method(" >> $ParentClass.cc
		ParamCount=1
		for param in "$@"
		do
			if [[ "$param" = *:* ]]; then
				ParamType=`./getSuffix.sh "$param"`
				ParamName=`./getPrefix.sh "$param"`
				ValueType=`./getValue.sh Types.table "$ParamType"`
				if [ "$ValueType" != "Invalid" ]; then
					echo -ne "$ValueType& $ParamName" >> $ParentClass.cc
					if [ $ParamCount -lt $# ]; then
						echo -ne ", " >> $ParentClass.cc
					fi
				fi
			fi
			ParamCount=$[$ParamCount +1]
		done
		echo -ne ")\n{}\n\n" >> $ParentClass.cc 
	else
		echo -e "$error"
	fi
}


if (( $# >= 3 )); then
	#If type is void do this ->
	if [ $# -eq 3 ] || [ "$CType" = "void" ] || [ "$CType" = "Void" ] || [[ "$Ctype" = *:* ]] || [ "$CType" = "ValueLess" ]; then
		Parents=`./getParents.sh "InheritanceTree.txt"  "$Class"`
		VoidType "$@"
		if [ ! "$Parents" == "-1" ]; then
			for var in $Parents
			do
				shift
				VirtualVoidType "$var $@"
			done
		fi
		exit
	#Else if type is invalid do this ->
	elif [ "$Type" = "Invalid" ]; then
		echo -e "$error"
		exit
	#Else if valid type do this ->
	elif [ "$Type" != "Invalid" ]; then
		Parents=`./getParents.sh "InheritanceTree.txt"  "$Class"`	
		ValidType "$@"
		if [ ! "$Parents" == "-1" ]; then
			for var in $Parents
			do
				shift
				VirtualValidType "$var $@"
			done
		fi
		exit
	#Else output an error
	else
		echo -e "$error"
		exit
	fi
fi
