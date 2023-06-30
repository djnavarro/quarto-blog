// enumerated-types.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };
    Gender danielle_gender { Gender::female };
    Gender benjamin_gender { Gender::male };

    std::cout << "Danielle gender: " << static_cast<int>(danielle_gender) << std::endl;
    std::cout << "Benjamin gender: " << static_cast<int>(benjamin_gender) << std::endl;
    return 0; 
}
