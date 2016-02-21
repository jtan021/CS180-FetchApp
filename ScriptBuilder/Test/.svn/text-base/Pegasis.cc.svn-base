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
// Pegasis Implementation
//************************************************************

#include <string>
#include "./Bird.hh"
#include "./Horse.hh"
#include "./Pegasis.hh"

// Pegasis Constructor
Pegasis::Pegasis():Bird(), Horse()
{}

// Pegasis Destructor
Pegasis::~Pegasis()
{}

// Accessor of Name
std::string Pegasis::GetName() const
{
	return m_Name;
}

// Mutator of Name
void Pegasis::SetName(std::string& value)
{
	m_Name = value;
}

// Accessor of Gender
bool Pegasis::GetGender() const
{
	return m_Gender;
}

// Mutator of Gender
void Pegasis::SetGender(bool& value)
{
	m_Gender = value;
}

// Accessor of Age
int Pegasis::GetAge() const
{
	return m_Age;
}

// Mutator of Age
void Pegasis::SetAge(int& value)
{
	m_Age = value;
}

// Accessor of Height
int Pegasis::GetHeight() const
{
	return m_Height;
}

// Mutator of Height
void Pegasis::SetHeight(int& value)
{
	m_Height = value;
}

// Accessor of Weight
int Pegasis::GetWeight() const
{
	return m_Weight;
}

// Mutator of Weight
void Pegasis::SetWeight(int& value)
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
double Pegasis::getBMI() const
{
	return (703*m_Weight)/(m_Height*m_Height);
}

