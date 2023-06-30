// typecasting.cpp
#include <iostream>

int main() {
    // variable declarations
    int someInteger;
    short someShort;
    long someLong;
    float someFloat;
    double someDouble;

    // some operations that involve casts
    someInteger = 256;
    someInteger++;
    someShort = static_cast<short>(someInteger);
    someLong = someShort * 10000;
    someFloat = someLong + 0.785f;
    someDouble = static_cast<double>(someFloat) / 100000;

    // print output and return
    std::cout << someDouble << std::endl;
    return 0;
}