// add-with-overloading.cpp
#include <iostream>

int add_numbers(int x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

double add_numbers(double x, double y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

double add_numbers(int x, double y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return static_cast<double>(x) + y;
}

double add_numbers(double x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + static_cast<double>(y);
}


int main() {
    int int_a = 1;
    int int_b = 2;
    double dbl_c = 3.45;
    double dbl_d = 6.78;

    int int_ab = add_numbers(int_a, int_b);
    double dbl_cd = add_numbers(dbl_c, dbl_d);
    double dbl_abcd = add_numbers(int_ab, dbl_cd);
    std::cout << "result: " << dbl_abcd << std::endl;
    return 0;
}
