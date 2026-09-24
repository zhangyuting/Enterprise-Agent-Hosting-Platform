# Build the white paper with XeLaTeX.
#
#   make            build both editions into build/
#   make en         build the English edition only
#   make zh-CN      build the Simplified Chinese edition only
#   make release    build, then copy the PDFs into pdf/
#   make clean      remove build/
#
# Three XeLaTeX passes are run so that the table of contents, the lists of
# figures and tables, and all cross-references settle.

NAME   := enterprise-agent-hosting-platform
LATEX  := xelatex
FLAGS  := -interaction=nonstopmode -halt-on-error -file-line-error
BUILD  := build
PASSES := 1 2 3

EN_SRC := $(wildcard paper/en/*.tex paper/en/sections/*.tex)
ZH_SRC := $(wildcard paper/zh-CN/*.tex paper/zh-CN/sections/*.tex)

EN_PDF := $(BUILD)/$(NAME).en.pdf
ZH_PDF := $(BUILD)/$(NAME).zh-CN.pdf

.PHONY: all en zh-CN release clean

all: en zh-CN

en: $(EN_PDF)
zh-CN: $(ZH_PDF)

# $(1) = edition directory under paper/
define compile
	@mkdir -p $(BUILD)/$(1)
	@echo "==> Building $(1)"
	@cd paper/$(1) && for pass in $(PASSES); do \
	  echo "    pass $$pass"; \
	  $(LATEX) $(FLAGS) -output-directory=../../$(BUILD)/$(1) main.tex > /dev/null \
	  || { echo "XeLaTeX failed; last lines of the log:"; tail -n 40 ../../$(BUILD)/$(1)/main.log; exit 1; }; \
	done
	@cp $(BUILD)/$(1)/main.pdf $@
	@echo "    wrote $@"
endef

$(EN_PDF): $(EN_SRC)
	$(call compile,en)

$(ZH_PDF): $(ZH_SRC)
	$(call compile,zh-CN)

release: all
	@mkdir -p pdf
	cp $(EN_PDF) pdf/
	cp $(ZH_PDF) pdf/

clean:
	rm -rf $(BUILD)
