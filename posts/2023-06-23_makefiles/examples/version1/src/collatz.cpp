// collatz.cpp
#include <iostream>

int main() {
    int value = 39;
    std::cout << value;
    while (value != 1) {
        value = (value % 2 == 0) ? (value / 2) : (3 * value + 1);
        std::cout << " -> " << value;
    }
    std::cout << std::endl;
    return 0;
}