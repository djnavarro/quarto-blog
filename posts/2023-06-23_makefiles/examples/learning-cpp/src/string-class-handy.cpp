// string-class-handy.cpp
#include <iostream>
#include <string>

int main() {
    std::string owlbear { "owlbear" };
    std::string owl;
    std::string bear;
    int pos;

    // these methods don't change the value of owlbear
    owl = owlbear.substr(0, 3);  // .substr(pos, len)
    bear = owlbear.substr(3, 4);
    pos = owlbear.find("bear");  // .find(str)

    std::cout << owl << " is a substring of " << owlbear << std::endl;
    std::cout << bear << " is also substring of " << owlbear << std::endl;
    std::cout << "the " << bear << " substring starts at " << pos << std::endl;

    // this one does
    owlbear.replace(0, 3, "teddy"); // .replace(pos, len, str)
    std::cout << "a " << owlbear << " is a different string" << std::endl;
    return 0;
}