// species-first-pass.cpp
#include <iostream>
#include <string>
#include <optional>

class Species {
    private:
        // internal data structure
        std::string name_binomial;
        std::optional<std::string> name_common;

    public:
        // class constructor with one input
        Species(std::string binomial) {
            setBinomialName(binomial);
        }

        // class constructor with two inputs
        Species(std::string binomial, std::optional<std::string> common) {
            setBinomialName(binomial);
            setCommonName(common);
        }

        // methods to set names
        void setBinomialName(std::string name) { name_binomial = name; }
        void setCommonName(std::optional<std::string> name) { name_common = name; }

        // methods to retrieve names
        std::string getBinomialName() { return name_binomial; }
        std::optional<std::string> getCommonName() { return name_common; }

        // print method
        void print() {
            std::cout << name_binomial;
            if (name_common.has_value()) {
                std::cout << " (" << name_common.value() << ")";
            }
            std::cout << std::endl;
        }
};

int main() {
    Species yellow_plant { "acacia amoena" };
    Species purple_plant { "hardenbergia violacea", "happy wanderer" };
    yellow_plant.print();
    purple_plant.print();
    return 0;
}
