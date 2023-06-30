// structured-binding-asl.cpp
#include <iostream>
#include <tuple>
#include <string>

// somewhat absurd function used to illustrate the point
std::tuple<int, char, std::string> asl() {
    return {45, 'F', "Sydney"};
}

int main() {
    // use structured bindings to declare and assign multiple 
    // variables from the output returned by the function call
    auto [age, sex, location] = asl();

    // messages
    std::cout << "age: " << age << std::endl;
    std::cout << "sex: " << sex << std::endl;
    std::cout << "location: " << location << std::endl;
    return 0;
}
