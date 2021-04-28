# Commodore 6502ASM

This is the source code of the 6502/65C02/65CE02 assembler developed and used by Commodore for the C65 project.

It supports Commodore-style directives and is therefore mostly compatible with older Commodore source code, like the [cbmsrc](https://github.com/mist64/cbmsrc) collection.

This source is based on version "B0.0", dated 1989-06-14 and has been updated for modern compilers.

## Usage

The assembler command line consists of these file names and switches:

    C65> [object],[listing]=source[,source]...[,source][/switch]...[/switch]

Items enclosed in brackets `[...]` are optional.
The default file extentions are `.OBJ`, `.LST`, and `.SRC`, respectively.

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


Since the defaults are reasonable, a typical invokation of the assembler would be

    asm NAME,NAME=NAME

This will assemble `NAME.SRC` and output to disk `NAME.OBJ` and `NAME.LST`.
																 	
## Assembler Directives

* `.AORG`
* `.ASECT`
* `.BLIST`
* `.BYTE`
* `.CLIST`
* `.ELSE`
* `.ENDIF`
* `.ENDM`
* `.ENDR`
* `.END`
* `.FORMLN`
* `.GEN`
* `.IFB`, `.IFNB`, `.IFIDN`, `.IFNIDN`, `.IFDEF`, `.IFNDEF`, `.IFN`, `.IFE`, `.IFGT`, `.IFGE`, `.IFLT`, `.IFLE`
* `.INCLUDE`
* `.IRPC`
* `.IRPC`
* `.IRP`
* `.LIST`
* `.LOCAL`
* `.MACRO`
* `.MACRO`
* `.MESSG`
* `.MLIST`
* `.NCLIST`
* `.NLIST`
* `.NMLIST`
* `.NOGEN`
* `.PAGE`
* `.RADIX`
* `.REPT`
* `.REPT`
* `.RMB`
* `.SECT`
* `.SPACE`/`.SKIP`
* `.SUBTTL`
* `.TITLE`/`.NAM`
* `.WORD`

As long as they are unique, most directives are also accepted abbreviated to 3 characters or more, e.g. `.NMLIST` = `.NMLIS` = `.NMLI` = `.NML`.

## TODO

* Document assembler directives
* Change default filename extensions to lower case
* Convert K&R -> C90
* Fix LLVM/GCC warnings
