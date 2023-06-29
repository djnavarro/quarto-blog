// append-c-strings.cpp
#include <iostream>
#include <cstring>

char* paste_strings(const char* str1, const char* str2, const char* str3) {
    const unsigned long len1 { std::strlen(str1) };
    const unsigned long len2 { std::strlen(str2) };
    const unsigned long len3 { std::strlen(str3) };
    char* out { new char[len1 + len2 + len3 + 1] }; 
    std::strcpy(out, str1);
    std::strcat(out, str2);
    std::strcat(out, str3);
    return out;
}

int main() {
    std::cout << paste_strings("I", "hate", "this") << std::endl;
    return 0;
}