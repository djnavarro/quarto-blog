// stoi.cpp
#include <iostream>
#include <string>

int main() {
    std::string monetary_string {}, monetary_unit {};
    size_t index { 0 };
    int monetary_value { 0 };

    // number is stored as the return value, index is modified
    monetary_string = "    123AUD";
    monetary_value = std::stoi(monetary_string, &index);
    monetary_unit = monetary_string.substr(index, 3);

    std::cout << "value: " << monetary_value << ", unit: " << monetary_unit << std::endl;
    return 0;
}