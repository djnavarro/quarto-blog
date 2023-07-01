// string-class-examples.cpp
#include <iostream>
#include <string>

using namespace std;

int main() {
    string lowercase { "owl" };
    string uppercase { "OWL" };
    bool is_equal { lowercase == uppercase };
    bool is_lower_lower { lowercase < uppercase };
    bool is_upper_lower { uppercase < lowercase };
    cout << "is a lowercase string equal to its uppercase version? " << is_equal << endl;
    cout << "is a lowercase string 'less than' an uppercase string? " << is_lower_lower << endl;
    cout << "so is the uppercase string 'less than'? " << is_upper_lower << endl;
    return 0;
}