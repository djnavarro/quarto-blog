// try-catch.cpp
#include <iostream>
#include <stdexcept>

// a divide() function that throws an error for divide-by-zero
double divide(double numerator, double denominator) {
    if (denominator == 0) {
        throw std::invalid_argument { "Denominator cannot be 0." };
    }
    return numerator / denominator; 
}

int main() {
    try {
        std::cout << divide(13, 2) << std::endl;
        std::cout << divide(13, 0) << std::endl;
        std::cout << divide(13, 3) << std::endl;
    } catch (const std::invalid_argument& exception) {
        std::cout << "Exception caught: " << exception.what() << std::endl;
    }
    return 0;
}