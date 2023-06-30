// gender-switch-2.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };

    switch (Gender x { Gender::unspecified }; x) {
        case Gender::female:
        case Gender::male:
            std::cout << "Within the gender binary" << std::endl;
            break;
        case Gender::nonbinary:
        case Gender::other:
            std::cout << "Outside the gender binary" << std::endl;
            break;
        case Gender::unspecified:
            std::cout << "Gender unspecified" << std::endl;
    }
}
