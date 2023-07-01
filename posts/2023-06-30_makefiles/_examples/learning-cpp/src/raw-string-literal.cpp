// raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str { R"(Dear world,
I too would like to say "hello".)" };
    std::cout << str << std::endl;
    return 0;
}
