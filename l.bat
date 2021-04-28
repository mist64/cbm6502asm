rem
rem     batch file to link the PC version of the assembler
rem
rem     assumes that the libraries are in the default directory
rem        C:\lc\d (uses the large data, small code model)
rem
link asm+pass1+pass2+direct1+direct2+symbol+express+line+outline+macrodef+opcode+help,asm,asm/m,c:\lc\d\lcm+c:\lc\d\lc
