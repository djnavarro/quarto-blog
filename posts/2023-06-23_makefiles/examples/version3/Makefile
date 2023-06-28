src := $(wildcard src/*.cpp)
bin := $(patsubst src/%.cpp, bin/%, $(src))

all: dir $(bin)

# this target is silent
dir:
	@mkdir -p ./bin

# this target prints a human readable message
bin/%: src/%.cpp
	@echo "compiling" $< "to" $@
	@clang++ --std=c++20 $< -o $@

clean:
	@echo "deleting binary files"
	@rm -rf bin
