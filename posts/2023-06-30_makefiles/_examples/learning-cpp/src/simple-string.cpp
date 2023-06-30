// simple-string.cpp
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::vector<std::string> name = { "Daniela", "Jasmine", "Navarro", "Bullock" };
    for(std::string n : name) { std::cout << n << std::endl; }
    return 0;
}