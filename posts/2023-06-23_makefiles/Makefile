cpp_src := $(wildcard src/*.cpp)
cpp_out := $(patsubst src/%.cpp, bin/%, $(cpp_src))

all: dirs $(cpp_out) ../../_site/posts/2023-06-23_makefiles/index.html

dirs:
	@mkdir -p ./bin

bin/%: src/%.cpp
	@echo "[compiling]" $<
	@clang++-15 --std=c++20 $< -o $@

../../_site/posts/2023-06-23_makefiles/index.html: index.qmd
	@echo "[rendering]" $<
	@quarto render $< --quiet

clean:
	@echo "[deleting]  bin"
	@rm -rf bin

