// pointer-stack.cpp
#include <iostream>

int main() {
    int value { 8 };          // variable on the stack
    int* int_ptr { &value };  // declare pointer to it
    std::cout << *int_ptr + 2 << std::endl; // retrieve and print
    return 0;
}