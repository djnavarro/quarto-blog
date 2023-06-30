// array-danielle.cpp
#include <iostream>
#include <array>

int main() {
    std::array<char, 8> danielle = { 'D', 'a', 'n', 'i', 'e', 'l', 'l', 'e' };
    std::cout << "Danielle has " << danielle.size() << " letters." << std::endl;
}