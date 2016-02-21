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
#include "./CompressGenomicData.hh"
#include <iostream>
#include <stdlib.h> 

using namespace std;

int main(int argc, char** argv)
{
        // Checking the number of input parameters is correct
        if (argc < 2)
        {
                // An input file filename is needed.
                cerr <<"Usage: " << argv[0] << " <filename>" << endl;
                exit(0);
        }
        // Definition of an instance of CompressGenomicData
        CompressGenomicData dataObj;
        
        // Converting input parameter into filename (texts);
        string inputFile(argv[1]);
        std::string fna = ".fna";
        std::string cds = ".cds";
        std::string::size_type foundFNA = inputFile.find(cds);
        std::string::size_type foundCDS = inputFile.find(fna);
        if(foundFNA != std::string::npos || foundCDS != std::string::npos) {
            // Execute the Run command;
            dataObj.Run(inputFile);
        }
        else {
            std::cout << "Error: Invalid file passed in." << std::endl;
            std::cout << "Usage: " << argv[0] << " <File.fna/cds>." << std::endl;
        }
        return 0;
}
