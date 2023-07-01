// file-extension.cpp
#include <iostream>
#include <string>

std::string_view file_extension(std::string_view file_name) {
    return file_name.substr(file_name.rfind('.'));
}

int main() {
    // same content, different types
    std::string file1 { R"(c:\temp\badly named file.txt)" }; 
    const char* file2 { R"(c:\temp\badly named file.txt)" }; 

    // works for C++ strings, C strings, and string literals
    std::cout << file_extension(file1) << std::endl;
    std::cout << file_extension(file2) << std::endl;
    std::cout << file_extension(R"(c:\temp\badly named file.txt)") << std::endl;
    return 0;
}