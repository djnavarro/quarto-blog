// simple-reference.cpp
#include <iostream>

int main() {
    int x { 10 };     // original 
    int& x_ref { x }; // reference

    x_ref++; // change the reference, *and* the original
    std::cout << x << std::endl; // prints 11

    x++; // change the original, *and* the reference
    std::cout << x_ref << std::endl; // prints 12
    
    return 0;
}