// array-iterator.cpp
#include <iostream>
#include <array>

int main() {
    std::array<int, 6> fib = { 1, 1, 2, 3, 5, 8 };
    for(int f : fib) { std::cout << f << std::endl; }
    return 0;
}