FONTSDIR := fonts
# screen, ebook, prepress, printer, default
QUALITY := printer
# Impression sur papier a3, 156*2=312mm
BOOKLET_PAPER := {234mm,312mm}

all: book_printer.pdf

booklet: book_printer-book.pdf 

%.tex: %.md
	pandoc --pdf-engine lualatex  --template extended.tex \
		   --variable numbersections --toc --variable toc-depth=2 \
		   --variable documentclass=memoir --variable fontsize=12pt \
		   --filter pandoc-citeproc \
		   --verbose \
		   $< -o $@

%_annexes.tex: %.md
	pandoc --pdf-engine lualatex  --template extended.tex \
		   --variable numbersections --toc --variable toc-depth=2 \
		   --variable documentclass=memoir --variable fontsize=12pt \
		   --filter pandoc-citeproc \
		   --verbose \
		   $< annexes.md -o $@

%.pdf: %.tex
	OSFONTDIR=$(FONTSDIR) lualatex $<
	makeindex $*.idx
	OSFONTDIR=$(FONTSDIR) lualatex $<

%-book.pdf: %.pdf
    #
	pdfbook --papersize '$(BOOKLET_PAPER)' $<

%_$(QUALITY).pdf: %.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH  -dQUIET -sOutputFile="$@" "$<"

%.html: %.md
	pandoc --verbose $< -o $@

%.epub: %.md
	pandoc --verbose $< -o $@

clean:
	rm -f *.log *.aux *.ilg *.ind *.idx *.out *.toc *.pdf *.lof *.tex

.PHONY: clean

