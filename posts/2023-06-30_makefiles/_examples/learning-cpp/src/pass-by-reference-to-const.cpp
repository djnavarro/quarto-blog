// pass-by-reference-to-const.cpp
#include <iostream>
#include <string>

// str_print() declares a reference-to-const as the argument
void str_print(const std::string& x) {
    std::cout << x << std::endl;
}

int main() {
    std::string str { "hello cruel world" }; 
    str_print( str ); // passing a string variable works
    str_print( "goodbye cruel world" ); // so does passing a literal
    return 0;
}

