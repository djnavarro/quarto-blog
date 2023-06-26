cpp_src := $(wildcard src/*.cpp)
cpp_out := $(patsubst src/%.cpp, bin/%, $(cpp_src))

pandoc_src := $(wildcard notes/*.md)
pandoc_out := $(patsubst notes/%.md, docs/%.html, $(pandoc_src))

all: dirs $(cpp_out) $(pandoc_out) docs/style.css docs/.nojekyll docs/CNAME

dirs:
	@mkdir -p ./bin
	@mkdir -p ./docs

bin/%: src/%.cpp
	@echo "[compiling]" $<
	@clang++-15 --std=c++20 $< -o $@

docs/style.css: pandoc/style.css
	@echo "[copying]  " $<
	@cp pandoc/style.css docs/style.css

docs/.nojekyll:
	@echo "[writing]  " $@
	@touch docs/.nojekyll

docs/CNAME:
	@echo "[writing]  " $@
	@echo "learning-cpp.djnavarro.net" > docs/CNAME

docs/%.html: notes/%.md
	@echo "[rendering]" $<
	@pandoc $< -o $@ --template=./pandoc/template.html \
		--standalone --mathjax --toc --toc-depth 2

clean:
	@echo "[deleting]  docs"
	@echo "[deleting]  bin"
	@rm -rf docs
	@rm -rf bin

