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

//************************************************************
// CompressGenomicData Implementation
//************************************************************

#include "./CompressGenomicData.hh"
#include <sstream>  
#include <stdio.h>
#include <fstream>
#include <fcntl.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <sys/mman.h>

// CompressGenomicData Constructor
CompressGenomicData::CompressGenomicData()
 : m_fileSize(0)
{}

// CompressGenomicData Destructor
CompressGenomicData::~CompressGenomicData()
{}

// Accessor of fileSize
uint32_t CompressGenomicData::getfileSize() const
{
	return m_fileSize;
}

// Mutator of fileSize
void CompressGenomicData::setfileSize(uint32_t& num)
{
	m_fileSize = num;
}

// Accessor of totalLetters
uint32_t CompressGenomicData::gettotalLetters() const
{
	return m_totalLetters;
}

// Mutator of totalLetters
void CompressGenomicData::settotalLetters(uint32_t& num)
{
	m_totalLetters = num;
}


// Accessor of lettersPerLine
uint16_t CompressGenomicData::getlettersPerLine() const
{
	return m_lettersPerLine;
}

// Mutator of lettersPerLine
void CompressGenomicData::setlettersPerLine(uint16_t& num)
{
	m_lettersPerLine = num;
}

// Method: Encrypt
//**********************************************************
// Purpose:
//
// Implementation Notes:
//
// Pseudo Code: (Sorry if the pseudo code is ugly, brain dead)
//**********************************************************
// Output attempting to encrypt the file
// Add the .cds extension to the name
// Open the file to encrypt using ofstream and fopen and WRITE BINARY
// If the file to encrypt is empty
//	Output an error and exit
// Write the totalLetters and lettersPerLine to the encryptedFile in binary using fwrite
// Close the file opened by fopen using fclose because it is no longer being used
// Create the 8 bit variables necessary (A=0,C=1,G=2,T=3)
// Create the 8 bit variable to hold the encrypted value to be pushed onto the file ("encryptedData")
// Create a count variable equal to 4 (4 because each byte holds 4 letters)
// Create a total count variable that holds total number of letters
// Create variables to hold the remaining letters (if the total # is not divisible by 4) and hold the calculated remainder
// for the total size of the file to be encrypted
//	if the count == 0 or the countTotal==0
//		if the remainingShift != 0 and the count == finalCount
//			leftShift the "encryptedData" by the remainder variable
//		endif
//		output "encryptedData" to the newFile
//		reset count to 4 and encryptedData to 0
//	endif
//	if the current index of the pmap == 'A' or 'a'
//		left shift the encryptedData twice
//		exclusive or encryptedData with variable A
//	endif
//	if the current index of the pmap == 'C' or 'c'
//		left shift the encryptedData twice
//		exclusive or encryptedData with variable C
//	endif	
//	if the current index of the pmap == 'G' or 'g'
//		left shift the encryptedData twice
//		exclusive or encryptedData with variable G
//	endif
//	if the current index of the pmap == 'T' or 't'
//		left shift the encryptedData twice
//		exclusive or encryptedData with variable T
//	endif
// end for loop
// delete the old file
// close files
// output that encrypting was successful
//**********************************************************
void CompressGenomicData::Encrypt(uint8_t *pmap, std::string outputFile)
{
    std::cout << "Attempting to encrypt " << outputFile << "... " << std::endl;
    //Open "newFile" to store encrypted data
    std::string outFile = outputFile;
    outFile += ".cds";
    std::ofstream newFile;
    newFile.open(outFile.c_str());
    
    //Write total # of bases and total letters per line to file
    FILE *encryptedFile;
    uint32_t totalLetters[] = { m_totalLetters };
    uint16_t lettersPerLine[] = { m_lettersPerLine };
    encryptedFile = fopen(outFile.c_str(), "wb");

    if(encryptedFile == NULL) {
        std::cout << "Error: Invalid file" << std::endl;
        exit(1);
    }

    fwrite(totalLetters, sizeof(uint32_t), 1, encryptedFile);
    fwrite(lettersPerLine, sizeof(uint16_t), 1, encryptedFile);
    fclose(encryptedFile);

    //Encrypt and push onto outputFile.cds
    newFile.seekp(0, newFile.end);
    uint8_t A = 0;
    uint8_t C = 1;
    uint8_t G = 2;
    uint8_t T = 3;
    uint8_t encryptedData = 0;
    int count = 4;
    int countTotal = m_totalLetters;
    int remainingBases = countTotal%4;
    int remainingShift = 2 * (4 - remainingBases);
    int finalCount = 4 - remainingBases;
    
    for(int i = 0; i < m_fileSize; ++i)
    {      
        if(count == 0 || countTotal == 0) {
            if(remainingShift != 0 && count == finalCount) {
                encryptedData = encryptedData << remainingShift;
            }
            newFile << encryptedData;
            count = 4;
            encryptedData = 0;
        }
        if(pmap[i] == 'a' || pmap[i] == 'A') {
            encryptedData = encryptedData << 2;
            encryptedData ^= A;
            count--;
            countTotal--;
        }
        else if(pmap[i] == 'c' || pmap[i] == 'C') {
            encryptedData = encryptedData << 2;
            encryptedData ^= C;
            count--;
            countTotal--;
        }
        else if(pmap[i] == 'g' || pmap[i] == 'G') {
            encryptedData = encryptedData << 2;
            encryptedData ^= G;
            count--;
            countTotal--;
        }
        else if(pmap[i] == 't' || pmap[i] == 'T') {
            encryptedData = encryptedData << 2;
            encryptedData ^= T;
            count--;
            countTotal--;
        }
    }
    remove(outputFile.c_str());
    newFile.close();
    std::cout << outFile << " successfully encrypted." << std::endl;
    return;
}


// Method: Decrypt
//**********************************************************
// Purpose: Decrypt the .CDS file and store the decrypted results in fileName.fna
//
// Implementation Notes:
//
// Pseudo Code:
//**********************************************************
// Output attempting to decrypt
// Open the file in READ BINARY mode with fopen to read by bytes
// If the file is empty
//	output an error and exit
// Remove the .cds extension from the file name and store it within a string outFile
// Create the file
// Obtain the total number of letters from the first 32 bits of the encrypted file
// Obtain the total letters per line from the next 16 bits of the encrypted file
// Create variables holding the decoded values and bit masks
// Create a total count variable and lettersPerLine count variable
// Set them equal to the extracted total number of letters and total letters per line, respectively
// Read contents of the encrypted file into a 8 bit integer pointer "encryptedLetters"
// for the total numbers of letters encrypted inside the file
// 	do this 4 times using for loop (4 times because 1 byte holds 4 letters)
//		set an 8 bit integer "temp" equal to the current index of encryptedLetters
//		if lettersPerLine counter == 0
//			output a new line to the new file
//			reset lettersPerLine counter to decrypted lettersPerLine
//		if count == 4
//			bit mask "temp" with mask 1 and right shift 6 times
//		else if count == 3
//			bit mask "temp" with mask 2 and right shift 4 times
//		else if count == 2
//			bit mask "temp" with mask 3 and right shift 2 times
//		else if count == 1
//			bit mask "temp" with mask 4
//		if temp == A
//			output A to new file
//		if temp == C
//			output C to new file
//		if temp == G
//			output G to new file
//		if temp == T
//			output T to new file
//		decrement lettersPerLine counter
//		decrement total letters counter
//	end for loop
// end for loop
// delete original file
// close files
// Output decrypting was successful
//**********************************************************
void CompressGenomicData::Decrypt(std::string outputFile)
{
    std::cout << "Attempting to decrypt " << outputFile << "... " << std::endl;
    //Open the file in READ BINARY mode
    FILE *encryptedFile;
    encryptedFile = fopen(outputFile.c_str(), "rb");
    if(encryptedFile == NULL) {
        std::cout << "Error: Invalid file" << std::endl;
        exit(1);
    }
    //Remove .cds extension from the file name
    std::string outFile = outputFile;
    std::string cds = ".cds";
    std::string::size_type i = outFile.find(cds);
    outFile.erase(i, cds.length());

    //Create the file
    std::ofstream newFile;
    newFile.open(outFile.c_str());
    
    //Obtain total number of letters and total letters per line
    uint32_t obtainedTotalLetters;
    uint16_t obtainedTotalLettersPerLine;
    
    fread(&obtainedTotalLetters, sizeof(uint32_t), 1, encryptedFile);
    fread(&obtainedTotalLettersPerLine, sizeof(uint16_t), 1, encryptedFile);

    int totalCount = obtainedTotalLetters;
    int lettersPerLineCount = obtainedTotalLettersPerLine;
    int currBitCount = 4;
    //Bit Mask Variables
    uint8_t Mask1 = 0xC0;
    uint8_t Mask2 = 0x30;
    uint8_t Mask3 = 0xC;
    uint8_t Mask4 = 0x3;
    //Decoded Values
    uint8_t A = 0;
    uint8_t C = 1;
    uint8_t G = 2;
    uint8_t T = 3;
    uint8_t *encryptedLetters = (uint8_t*)malloc (sizeof(uint8_t)*m_fileSize);
    fread(encryptedLetters, sizeof(uint8_t), totalCount, encryptedFile);
    
    for(int i = 0; totalCount >= 1; ++i) {
        for(int currBitCount = 4; currBitCount >= 1 && totalCount >= 1; currBitCount--) {
            uint8_t temp = encryptedLetters[i];
            if(lettersPerLineCount == 0) {
                newFile << std::endl;
                lettersPerLineCount = obtainedTotalLettersPerLine;
            }
            if(currBitCount == 4) {
                temp = (encryptedLetters[i] & Mask1) >> 6;
            }
            if(currBitCount == 3) {
                temp = (encryptedLetters[i] & Mask2) >> 4;
            }
            if(currBitCount == 2) {
                temp = (encryptedLetters[i] & Mask3) >> 2;
            }
            if(currBitCount == 1) {
                temp = (encryptedLetters[i] & Mask4);
            }
            if(temp == A) {
                newFile << "A";
            }
            if (temp == C) {
                newFile << "C";
            }
            if (temp == G) {
                newFile << "G";
            }
            if (temp == T) {
                newFile << "T";
            }
            lettersPerLineCount--;
            totalCount--;
        }
    }
    remove(outputFile.c_str());
    fclose(encryptedFile);
    newFile.close();
    std::cout << outFile << " successfully decrypted." << std::endl;
    return;
}


// Method: Run
//**********************************************************
// Purpose: Open the file and encrypt/decrypt the file according to its extension
//
// Implementation Notes:
// Credit to Rashid Ounit for Code for Opening/Closing Files and setting up the Memory Map
//
// Pseudo Code:
//**********************************************************
// Open the file in READ ONLY mode
// Estimate the size of the file and store it in a 32-bit integer "fileSize"
// If the file can't be accessed or is empty
//      output error
// Map the full content of the file (m_fileSize) with flag: PROT_READ, MAP_PRIVATE
// If the pmap fails or the mapping produced an error
//      output an error and close the file descriptor
// Count each item in the file that is not a newline character and store the count in the totalLetters private variable
// Count each item in a line from the file and store that count in the lettersPerLine private variable
// Check the file extension, if it is a .CDS file run Decrypt, else run Encrypt
// Update/Apply changes to be made to the file before closing
// Delete the mmapping
// Close the file
//**********************************************************
bool CompressGenomicData::Run(std::string& inputFile)
{
    // Open the file in READ ONLY mode
    int fileDescriptor = open(inputFile.c_str(), O_RDONLY);

    // Estimate the size of the file and store it in “fileSize”
    std::ifstream in(inputFile.c_str(), std::ios::binary | std::ios::ate);
    uint32_t fileSize = in.tellg();
    setfileSize(fileSize);
    
    // Check if the file can be accessed and is not empty
    if (fileDescriptor == -1 || fileSize == 0)
    {
        std::cerr << "Failed to open " << inputFile << std::endl;
        return false;
    }
    
    // Map the full content of the file (m_fileSize) with flag: PROT_READ, MAP_PRIVATE
    uint8_t *pmap = NULL;	
    pmap = (uint8_t*) mmap(0, fileSize, PROT_READ, MAP_PRIVATE, fileDescriptor, 0);
    
    // Check if the mapping produced an error
    if ( pmap == MAP_FAILED )
    {
        close(fileDescriptor);
        std::cerr << "Failed to mmapping the file." << std::endl;
        return false;
    }
    
    // Set m_totalLetters
    uint32_t totalLetters = 0;
    for ( int i = 0; i < fileSize; ++i ) {
        if (pmap[i] != '\n') {
            totalLetters += 1;
        }
    }
    settotalLetters(totalLetters);
    
    // Set m_lettersPerLine
    uint16_t lettersPerLine = 0;
    for ( int i = 0; i < m_fileSize; ++i ) {
        if (pmap[i] == '\n')
            break;
        lettersPerLine += 1;
    }
    setlettersPerLine(lettersPerLine);
    
    std::string fileType ("cds");
    std::size_t found = inputFile.find(fileType);
    if(found == std::string::npos) {
        Encrypt(pmap, inputFile);
    }
    else if (found != std::string::npos) {
        Decrypt(inputFile);
    }
    
    // Update/Apply changes to be made to the file before closing
    msync(pmap, m_fileSize, MS_SYNC);
    
    // Delete the mapping 
    if (munmap(pmap, m_fileSize) == -1)
    {
        std::cerr << "Error un-mmapping the file." << std::endl;
        return false;
    }
    // close the file
    close(fileDescriptor);    
}

