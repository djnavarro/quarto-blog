// string-class-examples.cpp
#include <iostream>
#include <string>

using namespace std;

int main() {
    string a { "owl" };
    string b { "bear" };
    string c;

    // overloaded + operator for strings
    c = a + b;
    cout << a << " + " << b << " = " << c << endl;
    
    // overloaded += operator
    c += " is the strangest creature"; 
    cout << c << endl;

    // extracting elements with []
    cout << "the 17th character in '" << c << "' is " << c[16] << endl; 

    return 0;
}