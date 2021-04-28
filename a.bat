
rem
rem     batch file to compile PC version of the assembler
rem
rem     assumes that Lattice C is installed in the default directory
rem             C:\LC and that the INCLUDE environment is SET
rem
del *.obj
lc -mds asm
lc -mds pass1
lc -mds pass2
lc -mds direct1
lc -mds direct2
lc -mds symbol
lc -mds express
lc -mds line
lc -mds outline
lc -mds macrodef
lc -mds opcode
lc -mds help
l
