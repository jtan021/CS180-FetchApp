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
// Unicorn Implementation
//************************************************************

#include "./Bird.hh"
#include "./Horse.hh"
#include "./Pegasis.hh"
#include "./Unicorn.hh"

// Unicorn Constructor
Unicorn::Unicorn()
{}

// Unicorn Destructor
Unicorn::~Unicorn()
{}

// Accessor of Test
Bird* Unicorn::GetTest() const
{
	return m_Test;
}

// Mutator of Test
void Unicorn::SetTest(Bird*& value)
{
	m_Test = value;
}

// Accessor of Test2
Horse* Unicorn::GetTest2() const
{
	return m_Test2;
}

// Mutator of Test2
void Unicorn::SetTest2(Horse*& value)
{
	m_Test2 = value;
}

// Accessor of Test3
Pegasis* Unicorn::GetTest3() const
{
	return m_Test3;
}

// Mutator of Test3
void Unicorn::SetTest3(Pegasis*& value)
{
	m_Test3 = value;
}

