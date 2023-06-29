// add-with-logging.cpp
#include <iostream>

int add_numbers(int x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

int main() {
    int a = 1;
    int b = 2;
    int c = 3;
    int sum1 = add_numbers(a, b);
    int sum2 = add_numbers(sum1, c);
    std::cout << "result: " << sum2 << std::endl;
    return 0;
}
