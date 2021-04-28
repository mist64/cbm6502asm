The 4502 assembler command line consists of these file names and switches:

C65> [object],[listing]=source[,source]...[,source][/switch]...[/switch]

Items enclosed in brackets [...] are optional.
The default file extentions are .OBJ, .LST, and .SRC, respectively.

Switches  (either upper or lower case):

        /A     absolute assembly (default)
        /Cn    cpu instruction set:
                   /C0 for NMOS 6502
                   /C1 for CMOS 6502
                   /C2 for CMOS 6502 w/bit instructions
                   /C3 for Commodore 4502 (default)
        /Dpath specify path for intermediate file (usually RAM disk on PCs).
        /H     help - prints this message
        /L     assume long branches on pass1. (default= assume short branches)
        /Mnnn  maximum macro nesting depth (default=50, limits=2-999).
        /Pnn   maximum number of passes to try (default=15, limits=2-99).
        /N     don't print errors to console during assembly
        /R     relocatable assembly
               (illegal since this is an absolute assembler only)
        /S     narrow list format
        /T     don't print symbol table
        /V     don't print cross reference
        /X     print cross reference (default)


Typically, I simply type ASM to invoke the assembler, and at the C65> prompt
I simply type  NAME,NAME=NAME  since the defaults are reasonable.

This will assemble NAME.SRC and output to disk NAME.OBJ and NAME.LST.
                                                                 
If you encounter any bugs, please let me know.  This assembler is compatible
with similar assemblers for the C128 and DEC VAX/VMS systems.

Fred Bowen
6/14/89




