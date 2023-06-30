# the "all" target is a set of other targets
all: dir bin/collatz bin/species bin/swap

# the "dir" target creates a directory for the binaries
dir:
	mkdir -p ./bin

# the "bin/collatz" target compiles the collatz.cpp program
bin/collatz: src/collatz.cpp
	clang++ --std=c++20 src/collatz.cpp -o bin/collatz

# the "bin/species" target compiles the species.cpp program
bin/species: src/species.cpp
	clang++ --std=c++20 src/species.cpp -o bin/species

# the "bin/swap" target compiles the swap.cpp program
bin/swap: src/swap.cpp
	clang++ --std=c++20 src/swap.cpp -o bin/swap

# the "clean" target deletes all binary files
clean:
	rm -rf bin
