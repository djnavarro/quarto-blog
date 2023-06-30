// validation-check.cpp
#include <iostream>
#include <ctime>

bool valid_time() {
    std::time_t elapsed = std::time(nullptr);
    bool is_valid = elapsed % 2 == 0;
    if (is_valid) {
        std::cout << elapsed << " seconds since the epoch" << std::endl;
    }
    return is_valid;
}

int main() {
    bool valid;
    int i = 0;
    do {
        i++;
    } while (!valid_time());
    std::cout << "attempts = " << i << std::endl;
    return 0;
}