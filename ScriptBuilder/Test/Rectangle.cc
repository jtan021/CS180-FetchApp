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
// Rectangle Implementation
//************************************************************

#include "./Rectangle.hh"

// Rectangle Constructor
Rectangle::Rectangle()
{}

// Rectangle Destructor
Rectangle::~Rectangle()
{}

// Accessor of Length
int Rectangle::GetLength() const
{
	return m_Length;
}

// Mutator of Length
void Rectangle::SetLength(int& value)
{
	m_Length = value;
}

// Accessor of Width
int Rectangle::GetWidth() const
{
	return m_Width;
}

// Mutator of Width
void Rectangle::SetWidth(int& value)
{
	m_Width = value;
}

// Method: getArea
//**********************************************************
// Purpose:
//
// Implementation Notes:
//
//**********************************************************
double Rectangle::getArea() const
{
	return 1;
}

