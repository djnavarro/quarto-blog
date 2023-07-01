// mean-value.cpp
#include <iostream>
#include <initializer_list>

double mean(std::initializer_list<double> values) {
    double tot = 0;
    for (double v : values) {
        tot += v;
    }
    return tot / values.size();
} 

int main() {
    double x_bar = mean({ 2.3, 1.5, 7.8, 11.0 });
    double y_bar = mean({ 102.5, 59.1, 98.2 });
    std::cout << "mean x: " << x_bar << std::endl;
    std::cout << "mean y: " << y_bar << std::endl;
    return 0;
}
