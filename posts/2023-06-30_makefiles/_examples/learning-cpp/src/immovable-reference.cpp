// immovable-reference.cpp
#include <iostream>

int main() {
    int x { 3 };
    int y { 4 };

    int& x_ref { x };
    x_ref = y;  // changes the value of x to match y
    std::cout << x << std::endl;

    return 0;
}