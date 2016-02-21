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

#ifndef Horse_hh
#define Horse_hh

//************************************************************
// Class Name: Horse
//
// Design:
//
// Usage/Limitations:
//
//*************************************************************

#include <string>

class Horse
{
	public:
	Horse();
	virtual ~Horse();

	//Accessor/Mutator of m_Name
	std::string GetName() const;
	void SetName(std::string& value);

	//Accessor/Mutator of m_Gender
	bool GetGender() const;
	void SetGender(bool& value);

	//Accessor/Mutator of m_Age
	int GetAge() const;
	void SetAge(int& value);

	//Accessor/Mutator of m_Height
	int GetHeight() const;
	void SetHeight(int& value);

	//Accessor/Mutator of m_Weight
	int GetWeight() const;
	void SetWeight(int& value);

	// Method:	getBMI
	// Output:	Decimal,
	// Input:	Valueless, 
	virtual double getBMI() const;

	protected:
	std::string m_Name;
	bool m_Gender;
	int m_Age;
	int m_Height;
	int m_Weight;
};

#endif
