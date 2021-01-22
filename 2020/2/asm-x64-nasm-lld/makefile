LINKER    = clang
ASSEMBLER = nasm
FORMAT    = win64

build : app.o
	$(LINKER) app.o -o app.exe
	
app.o : app.asm solution.asm numberParser.asm
	$(ASSEMBLER) -g -f $(FORMAT) -o $@ app.asm
	