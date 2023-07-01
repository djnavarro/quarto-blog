// string-escapes.cpp
#include <iostream>

int main() {
    const char* str { "Dear world,\nI should like to say \"hello\"." };
    std::cout << str << std::endl;
    return 0;
}