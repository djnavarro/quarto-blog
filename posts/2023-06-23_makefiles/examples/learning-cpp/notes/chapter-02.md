---
title: "2: Working with strings and string views"
---

[Back to top](index.html)


## C-style strings

The chapter begins with a discussion of strings in C. I understand why the book does this, but C-style strings are terrible and I want to make it a life goal never to use them again. In C, a string is literally an array of characters with a special `NUL` character (written `'\0'`) occupying the final slot. The string `"danielle"` is nothing more than a character array with values `{'d', 'a', 'n', 'i', 'e', 'l', 'l', 'e', '\0'}`. It's "fine", but only in the  everything-is-on-fire-dog-holding-a-cup-of-coffee-saying-this-is-fine sense of the term. It's especially horrible because the nul-terminator character is not included in the length of the string, and so you have to keep remembering that the length of every string is always +1 character longer than what it looks like. This leads to annoying code like this:

``` cpp
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
```

```
Ihatethis
```

I really, really do. 

## String literals

Next the book turns to string literals. It starts by defining terms: the terms "string literal" just refers to the actual string value itself, rather than the variable. So `"cat"` is a string literal. 

### Literal pooling

String literals pose different issues for languages than other kinds of literals because there's an incredibly large number of possible string literals, and a single string literal can be quite large. C++ (much like R, actually) does the smart thing from a memory perspective by having **literal pooling**. String literals are stored in read-only memory, which allows the compiler to optimise memory usage: every use of the `"cat"` string literal (or a string literal containing the entire Treaty of Westphalia) is treated as a reference to the same location in memory. That way you can use the same string over and over without wasting memory.

That all makes sense but this is where things become tricky. You can technically assign a string literal to a variable but string literal pooling produces weirdness. Formally a string literal of length $n$ is an array of $n$ `const char` types, but (for backward compatibility, apparently) the compiler doesn't enforce the implicit `const` in this context:

``` cpp
char* ptr { "cat" }; // string literal is assigned to a variable
ptr[1] = "o";        // the behaviour here is undefined
```

A slightly safer thing to do here is to explicitly use the `const` keyword. In this case, the compiler will explicitly recognise that we're trying to modify a `const` and throws an error:

``` cpp
const char* ptr { "cat" }; // string literal is assigned to a variable
ptr[1] = "o";              // compiler throws error because you can't change a const
```

The book has a few other details here, but I'm skipping them for now. 

### Escaping in string literals

As with most languages, string literals in C++ include escape sequences as use `\` as the way to escaping special characters. The book treats this as assumed knowledge, which probably makes sense becaus this isn't an introductory book and you're expected to have some prior coding experience before attempting to read it. But for what it's worth:

``` cpp
// string-escapes.cpp
#include <iostream>

int main() {
    const char* str { "Dear world,\nI should like to say \"hello\"." };
    std::cout << str << std::endl;
    return 0;
}
```

```
Dear world,
I should like to say "hello".
```

### Raw string literals

To make life a little easier, C++ also supports **raw string literals**, which do not support escape sequences and do not require escaping of quote marks. To open a raw string literal use `R"(`, and to close it use `)"`. Naturally, you cannot construct a raw string literal that actually contains `)"` as part of the string using this syntax. You can, however, include line breaks by literally typing "enter" when specifying the string. So, ugly as it is, this works:

``` cpp
// raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str { R"(Dear world,
I too would like to say "hello".)" };
    std::cout << str << std::endl;
    return 0;
}
```

```
Dear world,
I too would like to say "hello".
```

Finally, yes, C++ does support an extended raw string literal syntax in pretty much exactly the way you'd hope, where you can adopt a user defined sequence to signal the opening and closing of the string. For instance, to use `**` as the delimiter for an extended raw string literal corresponding to `"cat"`, I'd write `R"**(cat)**"`. It looks clunky in this case, but it's super handy for regular expressions and various other situations. A simple example:

``` cpp
// extended-raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str1 { R"**(Raw string literal containing "))**"};
    const char* str2 { R"%%(Raw string literal containing **)%%"};
    std::cout << str1 << std::endl;
    std::cout << str2 << std::endl;
    return 0;
}
```

```
Raw string literal containing ")
Raw string literal containing **
```

## The `std::string` class

At this point the book formally introduces the `std::string` class, a vastly superior option to using C style strings in most contexts. The class is defined in `<string>`, and functionality belongs to the `std` namespace. C++ strings support `+` and `+=` operators for concatenation, `==` for comparison, and subsetting with `[`. Some examples of this here:

```cpp
// string-class-examples.cpp
#include <iostream>
#include <string>

using namespace std;

int main() {
    string a { "owl" };
    string b { "bear" };
    string c;

    // overloaded + operator for strings
    c = a + b;
    cout << a << " + " << b << " = " << c << endl;
    
    // overloaded += operator
    c += " is the strangest creature"; 
    cout << c << endl;

    // extracting elements with []
    cout << "the 17th character in '" << c << "' is " << c[16] << endl; 

    return 0;
}
```

```
owl + bear = owlbear
owlbear is the strangest creature
the 17th character in 'owlbear is the strangest creature' is t
```

At this point the book spends quite a bit of time trying to convince C programmers that C++ strings are a better option if you need to do any string comparison, but of course I'm coming from interpreted languages like R and Python, so I'm coming to this part of the discussion already sold. I have not made any serious attempt to use C strings since 1994, and I have no intention of backsliding now. Suffice it to say logical operations on C++ strings have their usual meaning. Some silly code:

``` cpp
// string-class-examples.cpp
#include <iostream>
#include <string>

using namespace std;

int main() {
    string lowercase { "owl" };
    string uppercase { "OWL" };
    bool is_equal { lowercase == uppercase };
    bool is_lower_lower { lowercase < uppercase };
    bool is_upper_lower { uppercase < lowercase };
    cout << "is a lowercase string equal to its uppercase version? " << is_equal << endl;
    cout << "is a lowercase string 'less than' an uppercase string? " << is_lower_lower << endl;
    cout << "so is the uppercase string 'less than'? " << is_upper_lower << endl;
    return 0;
}
```

```
is a lowercase string equal to its uppercase version? 0
is a lowercase string 'less than' an uppercase string? 0
so is the uppercase string 'less than'? 1
```

All according to expectations, so let's move on. C++ strings have a lot of helpful methods that make it easier to work with them. A few examples are demonstrated in this program:

```cpp
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
```

```
owl is a substring of owlbear
bear is also substring of owlbear
the bear substring starts at 3
a teddybear is a different string
```

Anyway. The book has a whole thing here about "class template argument deduction" (CTAD), talking about how the type of a `vector` class can be automatically inferred from the values used when initialising the variable. It's a bit tricky in the case of strings because a string literal like `"cat"` is treated as `cont char*` by default, not `std::string`. That can lead to annoying problems when relying on CTAD for strings. Most of the time you probably want a vector of `std::string` types, not a vector of `const char*` types. The book points out that you can get around this by writing something `"cat"s`: the `s` at the end is used to specify that this string literal should give rise to `std::string` type when used for CTAD. 

Which. Fine. But honestly, I feel like this is a situation where it makes more sense to explicitly state that the thing you want is a vector of strings. In the following code, specifying `vector<string>` as the type makes so much more sense than trying to save some key strokes by typing `vector` and then appending a bunch of weird `s` characters to all my string literals:

``` cpp
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
```

```
Dani Danielle Daniela 
```

Anyway.

## Converting numerics to strings

Conversion from strings to numeric and vice versa requires a little thought. First, let's consider "high level" conversion from string to numeric types. We can do that with the `to_string()` function exposed by `<string>`. Here's an example:

``` cpp
// string-to-numeric.cpp
#include <iostream>
#include <string>

int main () {

    double dbl1 { 32.1435 };
    double dbl2 { 64.3452 };
    int int3 { 145 };
    int int4 { 522 };
    std::string str1;
    std::string str2;
    std::string str3;
    std::string str4;

    str1 = std::to_string(dbl1);
    str2 = std::to_string(dbl2);
    str3 = std::to_string(int3);
    str4 = std::to_string(int4);

    std::cout << "+ operator on double: " << dbl1 + dbl2 << std::endl;
    std::cout << "+ operator on string: " << str1 + str2 << std::endl;
    std::cout << "+ operator on integers: " << int3 + int4 << std::endl;
    std::cout << "+ operator on string: " << str3 + str4 << std::endl;

    return 0;
}
```

```
+ operator on double: 96.4887
+ operator on string: 32.14350064.345200
+ operator on integers: 667
+ operator on string: 145522
```

## Converting strings to numerics

To convert a string to a numeric type, you call one of the "sto*" functions. There's a naming convention for these functions reflecting the specific output type you want. It's comprehensible, albeit only barely and the names are pointlessly terse. The sheer effort that programmers will go to sometimes to write code that saves a few keystrokes at the cost of making the code look like utter gibberish is remarkable. Anyway:

- `stoi()` returns an `int`
- `stol()` returns a `long`
- `stoul()` returns an `unsigned long`
- `stoll()` returns a `long long`
- `stoull()` returns an `unsigned long long`
- `stof()` returns a `float`
- `stod()` returns a `double`
- `stold()` returns a `long double`

Peeking ahead a little, I have a suspicion this is something where templates come in handy? But I'm not yet ready for templates so whatever. The key thing for now is that in practice I'd be most likely to need `stoi()` or `stod()`, since integers and doubles are my go-to numeric types.

In any case, all of these functions have identical arguments, so for what it's worth here's the function signature for `stoi()`:

``` cpp
int stoi(const string& str, size_t *idx = 0, int base = 10);
```

- The first argument `str` is the to-be-converted string
- The second (optional) argument `*idk` is a pointer that takes the index of the first non-parsed character in the string
- The third (optional) argument `base` is an integer specifying the mathematical base (defaults to 10, but you could get hexadecimal numbers by setting `base = 16`).

When these functions are called, there are a couple of things to note. First, any leading whitespace in the string is ignored. Second, the functions have both a return value (the numeric value) and a side effect (the index of the first nonparsed character is updated). Inelegant as that feels, it can be handy. Here's a slighly tweaked version of the example given in the book that illustrates the point:

``` cpp
// stoi.cpp
#include <iostream>
#include <string>

int main() {
    std::string monetary_string {}, monetary_unit {};
    size_t index { 0 };
    int monetary_value { 0 };

    // number is stored as the return value, index is modified
    monetary_string = "    123AUD";
    monetary_value = std::stoi(monetary_string, &index);
    monetary_unit = monetary_string.substr(index, 3);

    std::cout << "value: " << monetary_value << ", unit: " << monetary_unit << std::endl;
    return 0;
}
```

```
value: 123, unit: AUD
```

## Low level conversions

At this point the book also discusses lower level functions to convert between strings and numeric values. The lower level functions require more care but can be much much faster. For now, I'm going to skip this section and leave it as a promissory note to myself that I may want to return to this one day.

## The `std::string_view` class

Until this very moment in my life I had not heard of C++ string views. Not because they aren't valuable, but, rather, because they were introduced only in C++17. Most R code that calls C++ uses C++11, and most other projects I've interacted with are also on older C++ versions. The problem solved by string views is to provide a read-only view of a string (it doesn't make copies) and as such is pretty handy when defining functions that take a read-only string as input.

The book uses the example of a function that extracts a file extension:

``` cpp
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
```

```
.txt
.txt
.txt
```

The thing to keep in mind is that you can't implicitly convert a string view to a string. You have to construct it explicitly. You can do this by calling the `.data()` method for a string view, or by explicit construction:

``` cpp
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
```

```
.txt
.txt
```

I think the key message implicit in these examples is that you always want to think about precisely what you are trying to do with the text. 

- Are you trying to pass a read-only string to a function: have it accept a string view
- Should the return value of a function be read-only? If yes, it can return a `std::string_view`, but if it's supposed to be modifiable then the return type you want is either `std::string` or -- if a reference is preferred -- `const std::string&`

There's also a need for care in regards to temporary strings. You don't want to store a view of a temporary string: if the string itself goes away, so too does the view. The example usd in the book is essentially this:

``` cpp
std::string s { "Hello" }; 
std::string_view v { s + " world" };  // badness!
std::cout << v << std::endl;
```

This is undefined behaviour, and apparently gives different results depending on the compiler and compiler settings. It took me a moment to understand where the badness is coming from. The issue here is that when `v` is initialised, a temporary string `s + " world"` is constructed, and then `v` is defined as string view of that temporary string. However, it really is a temporary string: it goes away at the end of line 2, which leaves `v` undefined (or more precisely, `v` is now a dangling pointer to a string that doesn't exist). That is the badness. 

## String formatting

The book has a long discussion at this point about C++20 style string formatting options using the `format()` function provided by the `<format>` library. It looks really nice, but doesn't seem to be supported in clang15 so I'm skipping this section. That said, I did a bit of extra reading elsewhere and the `<fmt>` library (external) appears to be the way you would do this properly in older versions of C++. That's nice and all, but again I'm going to leave this as a promissory note to future me. 

[Back to top](index.html)
