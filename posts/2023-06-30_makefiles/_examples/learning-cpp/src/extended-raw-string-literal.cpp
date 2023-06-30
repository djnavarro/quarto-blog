// extended-raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str1 { R"**(Raw string literal containing "))**"};
    const char* str2 { R"%%(Raw string literal containing **)%%"};
    std::cout << str1 << std::endl;
    std::cout << str2 << std::endl;
    return 0;
}
