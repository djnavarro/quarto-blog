// structured-binding.cpp
#include <iostream>
#include <array>

// somewhat absurd function used to illustrate the point
std::array<double, 3> get_coords() {
    std::array<double, 3> coords { 0.1, 0.2, 1.2 };
    return coords;
}

int main() {
    // use structured bindings to declare and assign multiple 
    // variables from the output returned by the function call
    auto [x, y, z] = get_coords();

    // messages
    std::cout << "x: " << x << std::endl;
    std::cout << "y: " << y << std::endl;
    std::cout << "z: " << z << std::endl;
    return 0;
}
