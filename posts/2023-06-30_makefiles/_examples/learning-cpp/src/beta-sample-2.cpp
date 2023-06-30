// beta-sample-2.cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <array>
#include <functional>
#include <random>

// https://gist.github.com/klmr/62863c3d9f5827df23ae2e1415b0cb1b
template <typename T = std::mt19937>
auto get_random_generator() -> T {
    auto constexpr seed_bytes = sizeof(typename T::result_type) * T::state_size;
    auto constexpr seed_len = seed_bytes / sizeof(std::seed_seq::result_type);
    auto seed = std::array<std::seed_seq::result_type, seed_len>();
    auto dev = std::random_device();
    std::generate_n(begin(seed), seed_len, std::ref(dev));
    auto seed_seq = std::seed_seq(begin(seed), end(seed));
    return T{seed_seq};
}

void print_message(double value, double a, double b) {
    std::cout << "beta(" << a << "," << b << ") sample: " << value << std::endl;
}

std::vector<double> draw_betas(double rate, double a, double b) {
    // distributions
    std::gamma_distribution<double> gamma_a(a, 1.0);
    std::gamma_distribution<double> gamma_b(b, 1.0);
    std::poisson_distribution<int> poisson(rate);

    // mersenne twister numbers
    std::mt19937 mt { get_random_generator() };

    // draw poisson sample to determine number of betas
    int n = poisson(mt);

    // draw beta samples and return
    std::vector<double> beta_variates {};
    double x, y;
    for (int i = 0; i < n; i++) {
        x = gamma_a(mt);
        y = gamma_b(mt);
        beta_variates.push_back(x / (x + y));
    }
    return beta_variates;
}

int main() {
    const double a = 2.0; // shape parameter 1
    const double b = 1.0; // shape parameter 2
    const double rate = 2.4; // rate for poisson dist

    // draw samples
    std::vector<double> betas = draw_betas(rate, a, b);

    // print messages and return
    std::cout << "collected " << betas.size() << " samples" << std::endl;
    for (int i = 0; i < betas.size(); i++) {
        print_message(betas[i], a, b);
    }
    return 0;
}

