// swap.cpp
#include <iostream>

void swap(int& first, int& second) {
    int temp { first };
    first = second; 
    second = temp;
}

int main() {
    int x { 10 }, y { 20 };
    std::cout << "original x value is " << x << std::endl;
    std::cout << "original y value is " << y << std::endl;
    swap(x, y);
    std::cout << "swapped x is now " << x << std::endl;
    std::cout << "swapped y is now " << y << std::endl;

    return 0;
}