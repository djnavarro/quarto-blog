// poisson-conditional.cpp
#include <iostream>
#include <random>

int main() {
    // define a poisson distribution
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};
    std::poisson_distribution<int> sample_poisson(4.1);

    // sample a value and write first part of message
    int value = sample_poisson(mersenne);
    std::cout << "The sampled value of " << value;

    // remainder of message depends on the value
    if (value == 4) {
        std::cout << " is the modal value." << std::endl;
    } else if (value < 4) {
        std::cout << " is below the mode." << std::endl;
    } else {
        std::cout << " is above the mode." << std::endl;
    }
    return 0;
}
