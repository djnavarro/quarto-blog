// char-code.cpp
#include <iostream>

void print_ascii_code(char c) {
    std::cout << c << " has integer code " << static_cast<int>(c) << std::endl;
}

int main() {
    print_ascii_code('d');
    print_ascii_code('a');
    print_ascii_code('n');
    print_ascii_code('i');
}
