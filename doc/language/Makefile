LATEXMK=latexmk

TARGET=language
SOURCE=$(wildcard *.tex *.bib)
OUTPUT=$(TARGET).pdf

all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	$(LATEXMK) -pdf $(TARGET)

clean:
	$(LATEXMK) -C

.PHONY: all clean
