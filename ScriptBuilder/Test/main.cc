#include "./Rectangle.hh"
#include "./Shape.hh"
#include "./Square.hh"
#include "./Bird.hh"
#include "./Horse.hh"
#include "./Pegasis.hh"

#include <iostream>

using namespace std;

int main()
{
	Square obj;
	int A = 10;
	obj.SetLength(A);
	cout << "Obj length = " << obj.GetLength() << endl;
	cout << "Obj Area = " << obj.getArea() << endl;

	Pegasis Jon;
	int height = 72; //Height in inches
	int weight = 195; //Weight in pounds
	Jon.SetHeight(height);
	Jon.SetWeight(weight);
	cout << "Jon's height = " << Jon.GetHeight() << endl;
	cout << "Jon's weight = " << Jon.GetWeight() << endl;
	cout << "Jon's bmi = " << Jon.getBMI() << endl;
	return 0;
}
