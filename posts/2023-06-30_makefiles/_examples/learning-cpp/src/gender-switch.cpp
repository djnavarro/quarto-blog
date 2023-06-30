// gender-switch.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };
    Gender danielle_gender { Gender::female };

    std::cout << "Danielle's gender is ";
    switch (danielle_gender) {
        case Gender::female:
        case Gender::male:
            std::cout << "within the gender binary" << std::endl;
            break;
        case Gender::nonbinary:
        case Gender::other:
            std::cout << "outside the gender binary" << std::endl;
            break;
        case Gender::unspecified:
            std::cout << "unspecified" << std::endl;
    }
}
