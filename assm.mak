MODEL = /AC

asm.obj: asm.c 
        cl /c $(MODEL) asm.c

pass1.obj: pass1.c 
        cl /c $(MODEL) pass1.c

pass2.obj: pass2.c 
        cl /c $(MODEL) pass2.c

direct1.obj: direct1.c 
        cl /c $(MODEL) direct1.c

direct2.obj: direct2.c 
        cl /c $(MODEL) direct2.c

symbol.obj: symbol.c 
        cl /c $(MODEL) symbol.c

express.obj: express.c 
        cl /c $(MODEL) express.c

line.obj: line.c 
        cl /c $(MODEL) line.c

outline.obj: outline.c 
        cl /c $(MODEL) outline.c

macrodef.obj: macrodef.c 
        cl /c $(MODEL) macrodef.c

opcode.obj: opcode.c 
        cl /c $(MODEL) opcode.c

help.obj: help.c 
        cl /c $(MODEL) help.c

assm.exe: asm.obj pass1.obj pass2.obj direct1.obj direct2.obj symbol.obj \
           express.obj line.obj outline.obj macrodef.obj opcode.obj help.obj
        link asm+pass1+pass2+direct1+direct2+symbol+express+line+outline+macrodef+opcode+help,assm;
