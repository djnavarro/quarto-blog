cpp := $(patsubst src/%.cpp, bin/%, $(wildcard src/*.cpp))
notes := $(patsubst notes/%.md, docs/%.html, $(wildcard notes/*.md))
static := docs/.nojekyll docs/CNAME docs/style.css

all: dirs $(cpp) $(static) $(notes)

dirs:
	@mkdir -p ./bin
	@mkdir -p ./docs

$(cpp): bin/%: src/%.cpp
	@echo "[compiling]" $<
	@clang++-15 --std=c++20 $< -o $@

$(static): docs/%: static/%
	@echo "[copying]" $< 
	@cp $< $@

$(notes): docs/%.html: notes/%.md
	@echo "[rendering]" $<
	@pandoc $< -o $@ --template=./pandoc/template.html \
		--standalone --mathjax --toc --toc-depth 2

clean:
	@echo "[deleting] docs"
	@echo "[deleting] bin"
	@rm -rf docs
	@rm -rf bin

