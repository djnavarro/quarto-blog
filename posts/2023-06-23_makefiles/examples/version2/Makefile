# lists of filenames
src_files := $(wildcard src/*.cpp)
bin_files := $(patsubst src/%.cpp, bin/%, $(src_files))

# the "all" target is much simpler now
all: dir $(bin_files)

dir:
	mkdir -p ./bin

# each C++ binary is a target, the source is its prerequisite
bin/%: src/%.cpp
	clang++ --std=c++20 $< -o $@

clean:
	rm -rf bin
