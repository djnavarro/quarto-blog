// file-extension-2.cpp
#include <iostream>
#include <string>

std::string_view file_extension(std::string_view file_name) {
    return file_name.substr(file_name.rfind('.'));
}

void print_string(const std::string& str) {
    std::cout << str << std::endl;
}

int main() {
    std::string file { R"(c:\temp\badly named file.txt)" }; 

    // print_string(file_extension(file));              // fails
    print_string(file_extension(file).data());          // works
    print_string(std::string { file_extension(file) }); // works

    return 0;
}