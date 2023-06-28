post := 2023-06-23_makefiles
site_path := ../../_site/posts/$(post)
freeze_path := ../../_freeze/posts/$(post)
output_path := ../../_site/posts/$(post)/index.html

all: dirs subprojects $(output_path) end

dirs:
	@mkdir -p ./bin

subprojects:
	@echo "\n[ making subproject v1 ]"
	@$(MAKE) --directory=examples/version1 --no-print-directory
	@echo "\n[ making subproject v2 ]"
	@$(MAKE) --directory=examples/version2 --no-print-directory
	@echo "\n[ making subproject v3 ]"
	@$(MAKE) --directory=examples/version3 --no-print-directory

$(output_path): index.qmd
	@echo "\n[ rendering quarto document ]"
	@quarto render $< --quiet

end:
	@echo "\n"

clean:
	@echo "\n[ cleaning subprojects ]"
	@$(MAKE) clean --directory=examples/version1 --no-print-directory
	@$(MAKE) clean --directory=examples/version2 --no-print-directory
	@$(MAKE) clean --directory=examples/version3 --no-print-directory
	@echo "\n[ deleting quarto output ]"
	@rm -rf $(site_path)
	@rm -rf $(freeze_path)
	@echo "\n"
