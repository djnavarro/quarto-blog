// circles.cpp

struct CircleStruct {
    int x, y;
    double radius;
};

class CircleClass {
    public:
        CircleClass(int x, int y, double radius) 
            : m_x { x }, m_y { y }, m_radius { radius } {}
    private:
        int m_x, m_y;
        double m_radius;
};

int main() {
    // these both use uniform initialisation
    CircleStruct circle1 { 10, 10, 2.5 };
    CircleClass circle2 { 10, 10, 2.5};

    // pre C++11, you had to do this:
    CircleStruct circle3 = { 10, 10, 2.5 };
    CircleClass circle4(10, 10, 2.5);

    // note that this is not uniform initialisation
    int a = 3;
    int b(3);

    // these are both uniform
    int c = { 3 };
    int d { 3};

    return 0;
}
