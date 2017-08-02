
all : book

clean :
	rm -f index.html
	rm -f bin/sample-code-checker

test : cpptest texttest

texttest : *.md
	textlint -f unix *.md

cpptest : test-tool
	bin/sample-code-checker *.md

retest : test-tool
	bin/sample-code-checker retest /tmp/sample-code-checker/*.cpp

test-tool : bin/sample-code-checker

bin/sample-code-checker : bin/sample-code-checker.cpp
	g++ -D _ISOC11_SOURCE -std=c++14 --pedantic-errors -Wall -pthread -O2 -o bin/sample-code-checker  bin/sample-code-checker.cpp

book : index.html


index.html : *.md style.css
	pandoc -s --toc --toc-depth=6 --mathjax -o index.html -H style.css  pandoc_title_block *-*.md

index.md : *.md
	pandoc -s --toc --toc-depth=6 --mathjax -o index.md -H style.css  pandoc_title_block *-*.md

index.pdf : *.md
	pandoc --listings -s --toc --toc-depth=6 -o index.pdf --template template.tex --latex-engine lualatex   pandoc_title_block *-*.md

index.tex : *.md
	pandoc --listings -s --toc --toc-depth=6 -o index.tex --template template.tex --latex-engine lualatex   pandoc_title_block *-*.md

.PHONY : all book clean test test-tool texttest cpptest retest
