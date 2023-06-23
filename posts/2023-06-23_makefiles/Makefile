cpp_src := $(wildcard src/*.cpp)
cpp_out := $(patsubst src/%.cpp, bin/%, $(cpp_src))

post := 2023-06-23_makefiles
site_path := ../../_site/posts/$(post)
freeze_path := ../../_freeze/posts/$(post)
output_path := ../../_site/posts/$(post)/index.html

all: dirs $(cpp_out) $(output_path)

dirs:
	@mkdir -p ./bin

bin/%: src/%.cpp
	@echo "[compiling]" $<
	@clang++-15 --std=c++20 $< -o $@

$(output_path): index.qmd
	@echo "[rendering]" $<
	@quarto render $< --quiet

clean:
	@echo "[deleting]  bin"
	@rm -rf bin
	@echo "[deleting] " $(site_path)
	@rm -rf $(site_path)
	@echo "[deleting] " $(freeze_path)
	@rm -rf $(freeze_path)


