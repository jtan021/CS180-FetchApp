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

-e //************************************************************
// Test Implementation
//************************************************************

-e #include "./Test.hh"

// Test Constructor
Test::Test()
{}

// Test Destructor
Test::~Test()
{}

-e // Accessor of Test
Invalid Test::GetTest() const
{
	return m_Test;
}

-e // Mutator of Test
void Test::SetTest(Invalid& value)
{
	m_Test = value;
}

-e // Accessor of Test
Invalid Test::GetTest() const
{
	return m_Test;
}

-e // Mutator of Test
void Test::SetTest(Invalid& value)
{
	m_Test = value;
}

