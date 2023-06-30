compile := $(patsubst src/%.cpp, bin/%, $(wildcard src/*.cpp))

all: dir $(compile)

dir:
	@mkdir -p ./bin

$(compile): bin/%: src/%.cpp
	@echo "compiling" $< "to" $@
	@clang++ --std=c++20 $< -o $@

clean:
	@echo "deleting binary files"
	@rm -rf bin
