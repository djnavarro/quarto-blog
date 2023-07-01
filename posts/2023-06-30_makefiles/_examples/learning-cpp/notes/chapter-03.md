---
title: "3: Coding with style"
---

[Back to top](index.html)

Chapter 3 focuses on the elements of good coding style. The short version is very familiar. At the beginning of the chapter the following themes are listed:

- Documentation
- Decomposition
- Naming
- Use of the language
- Formatting

## Documentation

I found the section on documentation interesting, because it focuses very heavily on code comments (which generally target developers maintaining or extending the code), whereas most of my experience with writing documentation targets users who need to call the code. In that sense it seems like there's a meaningful difference between **documentation for developers** and **documentation for users**. The chapter seems to focus more on the former than the latter: regular users don't look at the source code to work out how to interact with the public facing API, they look for tutorials, API reference pages, and so on. It's only the devs (which, could of course include anyone submitting a pull request) who read the code comments!

### Comments explain the things that are hard to extract from the code

With that in mind, one thing I found especially interesting is that the book advocates for a much more verbose commenting style than I typically see in the wild (either in C++ or R). Here's what I mean. The book uses the example of a `saveRecord()` function with this signature:

``` cpp
int saveRecord(Record& record);
```

There's no actual source code provided, but *maaaaaaaybe* someone reading the source code would work out that this function will throw an exception if `openDatabase()` has not yet been called. However, the most likely scenario is that it's a pain in the arse for the reader of the code -- per the fundamental law of programming that code is harder to read than to write -- so it's best to preface the source code with a comment like this:

``` cpp
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

There are other things about this function that might not be obvious. Someone reading the code might notice that the `record` argument has type `Record&`: it's a reference to a non-const. A reader might wonder if that ought to be `const Record&`, so this should be explained:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database     
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

That makes a lot more sense. The `record` argument cannot be declared `const` because it's possible that the `saveRecord()` function will modify the original `Record` object to which it refers. 

As an aside, I'm genuinely delighted to see the author advocating that code comments preserve this level of detail. Over and over again I find myself reading through a code base where it is 100% clear to me that the developer thinks "oh this is obvious, you should just be able to read my code, it is totally self-documenting". This is almost *never* true. I've seen very little code that is truly self-documenting for a reader who is not the same person as the author. Of course, that doesn't mean every code base should be meticulously documented, it's more... if you document at the level where only future-you can easily read the code, then other people will be less inclined to interact with your code. That's a legitimate choice... the *vast* majority of my code on GitHub is like that because I'm not looking for other users. I wrote the code for myself, and I've documented it to exactly the level required to ensure that future-Danielle (who has similar skills and thought patterns to me, I presume!) will be able to make sense of it. 

### Sometimes a well-named class removes the need for a comment

Anyway, getting back on track, the book then asks the question of whether we should consider extending the documentation even further by explaining the `int` return type? We could, for example, do this:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database  
// Returns: int
//    An integer representing the ID of the saved record
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

It's pretty tempting to do this, because honestly that `int` isn't very comprehensible, and the reader would have to dig into the code a fair ways in order to make sense of it. However, a better approach would be to define a very simple `RecordID` class. Most likely, a `RecordID` object would simply store an integer, but the mere fact that we've defined the class and given it a comprehensible name ensures that the function signature of `saveRecord()` is quite a bit more comprehensible:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database     
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
RecordID saveRecord(Record& record);
```

Plus, it's a little more future proof: the `RecordID` class could be extended later if need be.

### Your code is a lot more complex than you think it is

The next point the book makes about commenting is that comments within a function serve an important purpose too. My experience has been that programmers grossly underestimate the complexity of their own code, and grossly overestimate the degree to which a reader of their code shares "common ground knowledge" with them. The book -- perhaps pointedly, I can't tell? -- gives the example of insertion sort. A loooooooooooooot of programmers would write this and think the code is "self-documenting":

``` cpp
void sort(int data[], size_t size) {
    for (int i { 1 }; i < size; i++) {
        int element { data[i] };
        int j { i };
        while (j > 0 && data[j - 1] > element) {
            data[j] = data[j - 1];
            j--;
        }
        data[j] = element;
    }
}
```

The book has words of wisdom here:

> You might recognize the algorithm if you have seen it before, but a newcomer probably wouldn't understand the way the code works.

The implication here is that if you believe this code "doesn't need comments", what you're really saying is "newcomers can fuck off". There's, um, quite a bit of that attitude in the programming world. The implicit assumption here that "everybody knows insertion sort (because undergrad compsci classes almost always use sorting algorithms for pedagogical purposes)" functions as a kind of cultural shibboleth. It ensures that the world remains closed to everyone who arrived to programming from a non-traditional background and didn't take those classes. 

The book then goes on to offer the following as an example of better documentation:

``` cpp
// Implements the "insertion sort" algorithm. The algorithm separates the 
// array into two parts -- the sorted part and the unsorted part. Each 
// element, starting at position 1, is examined. Everything earlier in the
// array is in the sorted part, so the algorithm shifts each element over
// until the correct position is found to insert the current element. When
// the algorithm finishes with the last element, the entire array is sorted.
void sort(int data[], size_t size) {

    // Start at position 1 and examine each element
    for (int i { 1 }; i < size; i++) {
        // Loop invariant:
        //    All elements in the range 0 to i-1 (inclusive) are sorted

        int element { data[i] };
        int j { i }; // j is the position in the sorted part where element will be inserted

        // As long as the value in the slot before the current slot in the 
        // sorted array is higher than the element, shift values to the right
        // to make room for inserting element (hence the name, "insertion 
        // sort") in the correct position
        while (j > 0 && data[j - 1] > element) {
            data[j] = data[j - 1]; // invariant: elements in the range j+1 to i are > element
            j--; // invariant: elements in the range i to i are > element
        }

        // At this point the current position in the sorted array is *not* greater
        // than the element, so this is its new position
        data[j] = element;
    }
}
```

It's actually rather surprising to me that the book goes this far in arguing for detailed internal documentation. Not going to lie, it does make me happy, because I can look at the second version and immediately understand what the code does. The first version? Not so much. 

At this point the book goes on a bit to talk about the idea of "commenting every line", which takes things to an extreme. Not surprisingly, the author concludes that in practice this is unwieldy. Sometimes it's useful to do that, but it's more the exception than the rule, and often the real advantage to doing so is that it helps the author of the code ensure that each line of code is doing something worth including!

It also leads naturally to an extension of the idea we saw earlier with the `RecordID` helper class:

### Sometimes a well-named function removes the need for a comment

In the middle of one of the examples of not-so-great commenting, the book shows a line of code that includes this comment:

``` cpp
if (result % 2 == 0) {        // If the result modulo 2 is 0 ...
```

This comment is almost completely useless because it's literally a redescription of the code. A slightly better version of the same comment would describe the *functionality* provided by this line of code:

``` cpp
if (result % 2 == 0) {        // If the result is an even number ...
```

But the moment you write something like this, you realise that you can eliminate the comment entirely by writing a helper function:

``` cpp
bool isEven(int value) { return value % 2 == 0; }
```

This helper is so obvious that it doesn't need any commenting, and better yet, if we invoke the helper function in the original context we don't need to comment that either:

``` cpp
if (isEven(result)) { 
```

This code is both easier to read *and* easier to maintain: by encapsulating the "semantics" into a helper function (or, in the earlier example, a helper class), the developer can write code that expresses the core meaning more transparently (`saveRecord()` returns a `RecordID`, and `isEven(result)` checks for evenness), and doesn't have to worry about the possibility that later edits will accidentally change the semantics of code without having those changes reflected in the comments.

(Though I will mention that one problem I've seen in large code bases that rely extensively on these tricks is that they run the risk of including so many of these helper functions and classes that it's really hard to figure out how all the parts fit together)

### Other stylistic comments on comments?

The book has a bunch of other recommendations about comment style. I mostly agree with these.

- Before adding a comment, see if you can rewrite the code to make it unnecessary. Helper functions, helper classes, sensible choice of variable names, etc, can be valuable. Yep, no disagreements here.
- Imagine someone else is reading your code. This might help you find things that need documentation. Okay yes, I agree, but at the same time I think it's important to think about *who* this other person is an what knowledge they might have. It's waaaaay too easy to accidentally end up imagining an "other" person who happens to have the exact same knowledge and experience that you do. Doing so leads to comments that don't help anyone except the specific person who wrote the code.
- Don't use comments for things that version control handles for you: `git blame` will tell you who wrote a particular code snippet etc.
- When calling some other API that someone else (again: someone else who isn't just "you wearing a different hat") might not be familiar with, include a link or reference to the relevant documentation for that API
- Take comments seriously: updating the code is *not* finished until you've updated the comments
- Avoid derogatory or offensive language. I mean... yeah.
- The author writes "Liberal use of inside jokes is generally considered OK." I would disagree. That works if you're writing a blog post for your friends, or whatever. It *doesn't* work when you're writing something that has to be understood by others. Too often, overusing inside jokes inside the codebase functions as shibboleths, and contributes to a culture that is hostile to outsiders. Yes, we all have to have some fun, but... inside jokes should be uses sparingly (not liberally), in my opinion.

## Decomposition

The central idea in decomposition is to write code in small, reusable chunks rather than putting all the code into one long function or script. To an extent we all agree that this is a good idea, but of course it's not something easy to formalise. I once worked on a project where the linter started yelling at you whenever the [cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity) of any function exceeded some largely arbitrary threshold. It mostly worked, but there were a couple of places in the code base where it actually made sense to dump many, many things into one tedious function. Because there wasn't a way of telling the linter to easy up, it became necessary to split the large function up into many smaller functions... but those smaller functions weren't actually any easier to understand. In fact it was worse, because the smaller functions were more arbitrary than the big one. 

But whatevs. That's probably the exception that proves the rule. On the whole it's a good idea to break up really big functions into smaller reusable ones. Probably the more important thing here is to look at methods to help you decompose your code when you've decided it's necessary.

### Refactoring tricks

Right, so the book starts this section by defining **refactoring**: restructuring your code, for whatever reason. It's a big topic in itself, but the book lists some tips. First, you can rewrite your code to allow for more abstraction:

- Encapsulate a field: Make the relevant field private, and write public get/set methods
- Generalise types: Create more general-purpose types to make code sharing/reuse easier

Second, you can break the code apart:

- Extract a method/function: Take part of a large method/function and make it into its own method/function to make the code easier to read
- Extract a class: Take parts of a big class and make it into its own smaller class.

Third, you can improve code names and location of code:

- Move a method/field to a more appropriate class or file
- Rename method or field to something that clarifies its role
- "Pull up": in the OOP context, move to a base class
- "Push down": again in the OOP context, move to a derived class

Those last two are a bit opaque to me but the rest makes sense. 

(The book includes the standard warning here about the importance of unit testing... don't try to refactor your code until you have some unit tests you trust. Otherwise it's too easy to end up ugly code that works, and ending up with pretty code that doesn't... which is not in fact helpful)

### Decomposition by design

The other possibility, of course, is to design your code to be modular from the very beginning. Fair point. There's a lot to be said for starting out with a "sketch" of the code plans in advance how the functionality will be decomposed. 

## Naming things

Ah, everyone's favourite topic. Quick summary of key points:

- Prefer names that disambiguate: `sourceData` and `outputData` are better than `dat1` and `dat2`
- Prefer names that are not too long: the book suggests `g_settings` is sufficient to specify a global setting, whereas `globalUserSpecificSettingsAndPreferences` is going overboard
- Prefer names that are not too short: `m_commonName` is sufficient to describe the variable and indicate that it is a data member, whereas `m_cn` doesn't tell the reader anything
- Prefer names that convey behaviour precisely: `computeDerivative()` tells you what the function does, whereas `doThing()` of course does not
- Prefer human readable names: `mersenneTwister` is comprehensible to a reader, `mt19937_64` is... not
- Prefer names that don't abbreviate, where possible: `sourceFile` is better than `srcFile` 
- As usual, don't use offensive names, and avoid inside jokes

Some specific comments on names for indexing variables, which are conventionally given the labels `i` and `j`:

- When indices are used to specify row and column indices in a dimensional object, it's often better to explicitly call them `row` and `col`. That way you never get confused about whether `i` refers to the row index or the column index.
- While it's *usually* conventional to assume that `i` indexes the outermost loop, `j` indexes the next loop, and `k` indexes the third level of nested indexing, it's sometimes more readable if `i` and `j` are replaced by something like `inner` and `outer`. More generally, choosing something meaningful helps. In the statistical context, for instance, `t` might be used to iterate over times, `g` iterates over groups, etc. I have found that helpful because those indexing variable are almost always a better match to subscripts or other variables that appear in the mathematical specification of a model. 

It's often valuable to have a system of comprehensible prefixes that make certain information immediately clear (at least to someone who knows the system) from the variable name. Examples of this:

- Use `m_` (for "member") to specify a data member within a class
- Use `s_` (for "static") to specify a static variable

The book goes on to suggest things like `b` for boolean, but in practice you can use `is` for this purpose: names like `isCompleted` and `isEven()` seem more sensible to me than `bCompleted` or `bEven()`

Another kind of prefixing is to always use `get` and `set` as the prefixes for methods that retrieve or modify member data for an object: `getCommonName()` and `setCommonName()` would likely be names used to get or set the `m_commonName` data member of a class. 

The book also mentions that `lowerCamelCase` and `UpperCamelCase` are traditionally used in C++ for methods and functions, with `UpperCamelCase` being the norm for classes, and `lowerCamelCase` for function/method names. Variables and data members tend to be `snake_case` or `lowerCamelCase`. That's one area where my intuitions are a bit askew coming from R, where `snake_case` predominates except when using encapsulated OOP methods. I'll try to remember that.

Other naming strategies:

- Using constants is helpful. If your code sets `const int SecondsPerHour { 3600 };` it's a lot easier to read later on when `SecondsPerHour` pops up in the subsequent code, and the reader isn't left to guess where the "magic number" 3600 comes from.
- Using custom exceptions. The book issues a promissory note that chapter 14 will explain all the error handling stuff properly, but the main thing for now is that if you do this well you can end up with more readable code. Makes sense.

## Formatting

I'm skimming this section. It's a long conversation about how disagreements over fairly arbitrary things can lead to messy code and broken hearts. Spaces vs tabs, where to put curly braces, when to insert line breaks, etc etc. As usual, I think the main thing is that there be *some* agreed upon style for a specific project that is followed as consistently as possible, within reason. 

[Back to top](index.html)



