// beta-sample.cpp
#include <iostream>
#include <vector>
#include <random>

void print_message(double value, double a, double b) {
    std::cout << "beta(" << a << "," << b << ") sample: " << value << std::endl;
}

std::vector<double> draw_betas(double rate, double a, double b) {
    // distributions
    std::gamma_distribution<double> gamma_a(a, 1.0);
    std::gamma_distribution<double> gamma_b(b, 1.0);
    std::poisson_distribution<int> poisson(rate);

    // mersenne twister numbers
    std::random_device rd;
    std::mt19937 mt(rd());

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

