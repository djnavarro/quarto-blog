// scope-resolution.cpp
#include <iostream>

// value() is scoped to the Five class
class Five  {
    public:
        int value() { return 5; }
};

// value() belongs to the global scope
int value() { return 10; }

// value() belongs to the twenty namespace
namespace twenty {
    int value() { return 20; }
}

int main() {
    Five five;
    std::cout << five.value() << std::endl;    // prints 5
    std::cout << value() << std::endl;         // prints 10
    std::cout << twenty::value() << std::endl; // prints 20
    return 0;
}
