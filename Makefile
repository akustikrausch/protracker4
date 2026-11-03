# protracker 4.1 - needs vasm (vasmm68k_mot)
VASM ?= vasmm68k_mot

ProTracker41: Protracker.asm $(wildcard src/*/*.asm src/*/*.i src/data/bin/* include/*.i)
	$(VASM) -no-opt -Fhunkexe -nosym -kick1hunks -o $@ $<

clean:
	rm -f ProTracker41
