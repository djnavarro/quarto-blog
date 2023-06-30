// string-vectors.cpp
#include <iostream>
#include <string>
#include <vector>

using namespace std;

int main() {
    vector<string> names { "Dani", "Danielle", "Daniela" };
    for (string name : names) {
        cout << name << " ";
    }
    cout << endl;
    return 0;
}