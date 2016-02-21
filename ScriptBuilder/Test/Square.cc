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
// Square Implementation
//************************************************************

#include "./Rectangle.hh"
#include "./Shape.hh"
#include "./Square.hh"

// Square Constructor
Square::Square():Rectangle(), Shape()
{}

// Square Destructor
Square::~Square()
{}

// Accessor of Length
int Square::GetLength() const
{
	return m_Length;
}

// Mutator of Length
void Square::SetLength(int& value)
{
	m_Length = value;
}

// Method: getArea
//**********************************************************
// Purpose:
//
// Implementation Notes:
//
//**********************************************************
double Square::getArea() const
{
	return m_Length*m_Length;
}

