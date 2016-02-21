/*
 * Course: CS 100 Summer Session II 2015
 *
 * First Name: Jonathan
 * Last Name: Tan
 * Username: jtan021
 * email address: jtan021@ucr.edu
 *
 *
 * AssignmentID (e.g. lab0, lab1,... , hw0, hw1,... ):<assID>
 * Filename:<file>
 *
 * I hereby certify that the contents of this file represent
 * my own original individual work. Nowhere herein is there
 * code from any outside resources such as another individual,
 * a website, or publishings unless specifically designated as
 * permissible by the instructor or TA.
 * I also understand that by cheating, stealing, plagiarism or
 * any other form of academic misconduct defined at
 * http://conduct.ucr.edu/policies/academicintegrity.html,
 * the consequences will be an F in the class, and additional
 * disciplinary sanctions, such as the dismissal from UCR.
 *
 */

//************************************************************
// Horse Implementation
//************************************************************

#include <string>
#include "./Horse.hh"

// Horse Constructor
Horse::Horse()
{}

// Horse Destructor
Horse::~Horse()
{}

// Accessor of Name
std::string Horse::GetName() const
{
	return m_Name;
}

// Mutator of Name
void Horse::SetName(std::string& value)
{
	m_Name = value;
}

// Accessor of Gender
bool Horse::GetGender() const
{
	return m_Gender;
}

// Mutator of Gender
void Horse::SetGender(bool& value)
{
	m_Gender = value;
}

// Accessor of Age
int Horse::GetAge() const
{
	return m_Age;
}

// Mutator of Age
void Horse::SetAge(int& value)
{
	m_Age = value;
}

// Accessor of Height
int Horse::GetHeight() const
{
	return m_Height;
}

// Mutator of Height
void Horse::SetHeight(int& value)
{
	m_Height = value;
}

// Accessor of Weight
int Horse::GetWeight() const
{
	return m_Weight;
}

// Mutator of Weight
void Horse::SetWeight(int& value)
{
	m_Weight = value;
}

// Method: getBMI
//**********************************************************
// Purpose:
//
// Implementation Notes:
//
//**********************************************************
double Horse::getBMI() const
{
	return 1;
}
