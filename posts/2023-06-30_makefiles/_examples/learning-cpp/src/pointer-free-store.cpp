// pointer-free-store.cpp
#include <iostream>

int main() {
    int* int_ptr { new int }; // declare pointer & allocate memory
    *int_ptr = 8;             // assign value to the allocated memory
    std::cout << *int_ptr + 2 << std::endl; // retrieve and print
    return 0;
}