// poisson-sample.cpp
#include <iostream>
#include <random>

int main() {
    // set seed using time, define PRNG with Mersenne Twister
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};

    // sample_poisson() draws from Poisson(4.1) and returns an integer.
    std::poisson_distribution<int> sample_poisson(4.1);

    // draw poisson sample (passing the PRNG as argument) and write to stdout
    std::cout << "poisson sample: " << sample_poisson(mersenne) << std::endl;
    return 0;
}
