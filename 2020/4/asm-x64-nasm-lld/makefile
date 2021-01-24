LINKER    = clang
ASSEMBLER = nasm
FORMAT    = win64

build : app.o
	$(LINKER) app.o -o app.exe
	
app.o : app.asm solution.asm numberParser.asm passportParser.asm part1.asm passportIterator.asm part2.asm
	$(ASSEMBLER) -g -f $(FORMAT) -o $@ app.asm
	