// poisson-initialised-conditional.cpp
#include <iostream>
#include <random>

int main() {
    // define a poisson distribution
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};
    std::poisson_distribution<int> sample_poisson(4.1);

    // conditional statement with an initialiser
    if (int x = sample_poisson(mersenne); x == 4) {
        std::cout << x << " is the modal value." << std::endl;
    } else if (x < 4) {
        std::cout << x << " is below the mode." << std::endl;
    } else {
        std::cout << x << " is above the mode." << std::endl;
    }
    return 0;
}
