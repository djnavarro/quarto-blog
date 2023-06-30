// string-to-numeric.cpp
#include <iostream>
#include <string>

int main () {

    double dbl1 { 32.1435 };
    double dbl2 { 64.3452 };
    int int3 { 145 };
    int int4 { 522 };
    std::string str1;
    std::string str2;
    std::string str3;
    std::string str4;

    str1 = std::to_string(dbl1);
    str2 = std::to_string(dbl2);
    str3 = std::to_string(int3);
    str4 = std::to_string(int4);

    std::cout << "+ operator on double: " << dbl1 + dbl2 << std::endl;
    std::cout << "+ operator on string: " << str1 + str2 << std::endl;
    std::cout << "+ operator on integers: " << int3 + int4 << std::endl;
    std::cout << "+ operator on string: " << str3 + str4 << std::endl;

    return 0;
}