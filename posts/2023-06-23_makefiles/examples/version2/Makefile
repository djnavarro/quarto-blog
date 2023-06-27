# lists of filenames
src := $(wildcard src/*.cpp)
bin := $(patsubst src/%.cpp, bin/%, $(src))

# the "all" target is much simpler now
all: dir $(bin)

dir:
	mkdir -p ./bin

# each C++ binary is a target, the source is its prerequisite
bin/%: src/%.cpp
	clang++ --std=c++20 $< -o $@

clean:
	rm -rf bin
