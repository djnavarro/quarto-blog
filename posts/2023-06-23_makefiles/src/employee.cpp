// employee.cpp
#include <iostream>
#include <sstream>
#include "employee.h"

int main() {
    // define the employee record
    Employee danielle;
    danielle.firstInitial = 'D';
    danielle.lastInitial = 'N';
    danielle.employeeNumber = 69;
    danielle.salary = 123456;

    // write to stdout
    std::stringstream ss;
    ss.str("");
    ss << "Employee: " << danielle.firstInitial << danielle.lastInitial;
    std::cout << ss.str() << std::endl;

    ss.str("");
    ss << "Employee number: #" << danielle.employeeNumber;
    std::cout << ss.str() << std::endl;

    ss.str("");
    ss << "Employee salary: $" << danielle.salary;
    std::cout << ss.str() << std::endl;

    return 0;
}