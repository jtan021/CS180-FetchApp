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

#ifndef Shape_hh
#define Shape_hh

//************************************************************
// Class Name: Shape
//
// Design:
//
// Usage/Limitations:
//
//*************************************************************


class Shape
{
	public:
	Shape();
	virtual ~Shape();

	//Accessor/Mutator of m_Length
	int GetLength() const;
	void SetLength(int& value);

	//Accessor/Mutator of m_Width
	int GetWidth() const;
	void SetWidth(int& value);

	// Method:	getArea
	// Output:	Decimal,
	// Input:	Valueless, 
	virtual double getArea() const;

	protected:
	int m_Length;
	int m_Width;
};

#endif
