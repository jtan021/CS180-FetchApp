/*
 * Course: CS 100 Summer Session II 2015
 *
 * First Name: Jonathan
 * Last Name: Tan
 * Username: jtan021
 * email address: jtan021@ucr.edu
 *
 *
 * AssignmentID (e.g. lab0, lab1,... , hw0, hw1,... ): HW3
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

#ifndef CompressGenomicData_hh
#define CompressGenomicData_hh

//************************************************************
// Class Name: CompressGenomicData
//
// Design:
//
// Usage/Limitations:
//
//*************************************************************

#include <stdio.h>
#include <stdint.h>
#include <string>

class CompressGenomicData
{
	public:
	CompressGenomicData();
	~CompressGenomicData();

	//Accessor/Mutator of m_fileSize
	uint32_t getfileSize() const;
    void setfileSize(uint32_t& num);
    
	//Accessor/Mutator of m_totalLetters
	uint32_t gettotalLetters() const;
    void settotalLetters(uint32_t& num);
    
	//Accessor/Mutator of m_lettersPerLine
	uint16_t getlettersPerLine() const;
    void setlettersPerLine(uint16_t& num);

	// Method:	Encrypt
	// Output:	Valueless,
	// Input:	Integer,
    //          Text,
	void Encrypt(uint8_t *pmap, std::string outputFile);
    
   	// Method:	Decrypt
	// Output:	Valueless,
	// Input:	Integer,
	//          Text,
	void Decrypt(std::string outputFile);

	// Method:	Run
	// Output:	Boolean,
	// Input:	Text, 
	bool Run(std::string& inputFile);

	private:
    uint32_t m_fileSize;
    uint32_t m_totalLetters;
    uint16_t m_lettersPerLine;
};

#endif
