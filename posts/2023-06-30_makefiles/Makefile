post := 2023-06-30_makefiles
html := ../../_site/posts/$(post)/index.html
examples = version1 version2 version3

# explicitly state that these targets aren't file names
.PHONY: all clean clean_quarto
.PHONY: $(patsubst %, build_%, $(examples))
.PHONY: $(patsubst %, clean_%, $(examples))

all: $(patsubst %, build_%, $(examples)) $(html)

$(patsubst %, build_%, $(examples)): build_%: _examples/%
	@echo "------------ building" $< "------------"
	@$(MAKE) -C $< --no-print-directory

$(html): index.qmd
	@echo "------------ rendering quarto ------------"
	@echo "rendering" $@
	@quarto render $< --quiet

$(patsubst %, clean_%, $(examples)): clean_%: _examples/%
	@$(MAKE) clean -C $< --no-print-directory

clean_quarto: 
	@rm -rf ../../_site/posts/$(post)
	@rm -rf ../../_freeze/posts/$(post)

clean: $(patsubst %, clean_%, $(examples)) clean_quarto
