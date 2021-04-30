# Commodore 6502ASM

This is the source code of the 6502/65C02/65CE02 assembler developed and used by Commodore for the C65 project.

It supports Commodore-style directives and is therefore mostly compatible with older Commodore source code, like the [cbmsrc](https://github.com/mist64/cbmsrc) collection.

This source is based on version "B0.0", dated 1989-06-14 from `4502-asm-for-pc.img` of the [Dennis Jarvis collection](http://6502.org/users/sjgray/dj/) and has been slightly updated:
* A UNIX-style Makefile has been added.
* The whole source has been linted into a more modern coding style.
* Some compiler warnings have been fixed.
* The behavior has been changed to default to lower case extensions.


## Usage

The assembler command line consists of these file names and switches:

    asm [object],[listing]=source[,source]...[,source][/switch]...[/switch]

Items enclosed in brackets `[...]` are optional.
The default file extentions are `.obj`, `.lst`, and `.src`, respectively.

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

    asm name,name=name

This will assemble `name.src` and output to disk `name.obj` and `name.lst`.


Since this assembler is backwards compatible with Commodore's HCD65 assembler, the following description has been adapted from chapter 2 of this service manual: [C128 Developers Package for Commodore 6502 Development (1987 Oct).pdf](http://www.zimmers.net/anonftp/pub/cbm/schematics/computers/c128/servicemanuals/C128_Developers_Package_for_Commodore_6502_Development_(1987_Oct).pdf).

## Macros

The macro facility provides text expansion and substitution capability. Macros are defined by enclosing a block of of text in `.MACRO` and `.ENDM` directives. All of the text between the two directives composes the body of the macro. When the `.MACRO` directive is encountered by the assembler, there must be a macro name in the label field. That name is used to call the macro. Whenever the assembler finds text in the operator field which is not preceded by a period (indicating a directive), it checks to see if that text is a macro name before checking to see if that text is an opcode mnemonic.

When a macro call is encountered in the source file, the text for the body of the macro with that name is substituted into the input stream where the macro call was, Therefore. one macro call can result in many lines of code for the assembler to handle.

Example of macro definition:

       ;the following macro clears the x and a registers.
       clr_reg .macro
               lda #0
               ldx #0
               .endm

Example of macro call:

       label   nop
               clr_reg
               nop

Resulting assembled code:

       label   nop
               lda #0
               ldx #0
               nop

Macros are expanded in a preprocessor before the input lines are fed to the assembler. They work entirely on a text substitution basis.

Macros allow arguments to be used. Dummy arguments, separated by commas, are declared as arguments to the `.MACRO` directive. Many arguments are allowed, the upper limit being determined by the maximum length of the input string. When a macro is called, the input text is expanded verbatim except where dummy arguments occur. In this case, the arguments following the call to the macro are substituted into the positions where the dummy arguments were in the macro definition.

Example macro for loading a and x with immediate data:

definition

       ldi     .macro arg
               lda #>arg
               ldx #<arg
               .endm

call

       label   ldi $1234

expansion

       label   lda #>$1234
               ldx #<$1234

Because the macro facility only understands text streams, but does not understand about specific fields, the user must be careful in the selection of dummy arguments. Using short arguments can lead to unexpected expansions. For example, this following source code performs unexpectedly:

definition:

       ;store value in arg into memory at loc.
       setloc  .macro a
               lda #a
               sta loc
               .endm

call:

       label   nop
               setloc $0F
               nop

expansion:

       label   nop
               ld$0F #$0F
               st$0F loc
               nop

This clearly erroneous expansion occurred because the macro facility blindy substitutes macro args wherever dummy args occur in the macro definition. One solution is to use longer dummy argument names. Another solution preferred by many users is to precede simple dummy argument names with a rarely used character. The percent symbol is a good choice.

definition:

       ;store value in arg into memory at loc.
       setloc  .macro %a
               lda #%a
               sta loc
               .endm

call:

       label   nop
               setloc $0F
               nop

expansion:

       label   nop
               lda #$0F
               sta loc
               nop

As previously stated, macros can have many arguments. Blank dummy arguments can also occur in macro definitions. Arguments occurring in macro calls which have no corresponding dummy argument in the macro definition are simply ignored. Blank arguments occurring in macro calls evaluate as nothing when the macro is expanded.

For example:

Definition:

       ld_chrs .macro %a,%b
               lda #'%a'
               ldx #'%b’
               .endm

Call:

       label   nop
               ld_chrs 1,,3
               nop

Expansion:

       label   nop
               lda #'1'
               ldx #''
               nop

Occasionally it is desirable to pass arguments to macros which contain characters like spaces or commas. Because these are normally stripped by the parser to delimit lines, or delimit arguments, this would seem impossible.

However, such an argument may be passed by placing them it inside angle brackets. Then, when the macro is to be expanded, the arguments are scanned for matching sets of angle brackets ( `<`,`>` ). If these are found, all the text between the angle brackets is passed as a single macro argument after the brackets are stripped away.

For example:

Definition:

       ld_chrs .macro %a,%b
               lda #'%a'
               ldx #'%b’
               .endm

Call:

       label   nop
               ld_chrs 1,<,>
               nop

Expansion:

       label   nop
               lda #'1'
               ldx #','
               nop

Many conditionals are supplied expressly for using inside of macros to allow detection of null fields, undefined symbols, etc. Other directives (`.REPT`, `.IRPC`, `.IRP`) are actually special cases of macros and work using many `.MACRO` like principles.


## Listing Format

The listing output has many features. The listing is paginated with several lines of information at the top of each page. Here is an example of a portion of a single page. Note that this page shows a call to the macro `LD_CHRS` used as an example in the previous sections describing macros.

       MY_PROGRAM  Commodore 6502ASM B0.0  Apr 29 20:39:04 2021  Page 1
       UTILITY SUBROUTINE utilities.src

       Error Addr  Code          Seq   Source statement
             8122  EA            7000  LABEL    NOP
       V     8123  A9 02         7001           LDA #$1002
                                 7002+          LD_CHRS 1,<,>
             8125  A9 31         7003A          LDA #'1'
             8127  A2 2C         7004A          LDX #','
             8129  EA            7005           NOP

The top line contains four things:

1) The program name as defined by the `.NAME` directive.
2) Information identifying the assembler and version number.
3) The date information as described by the BASIC startup file.
4) The page number.

The second line contains two things:

1) The text defined by the last `.SUBTTL` directive.
2) The current source file being read to generate this page.

The third line contains headers for the columns output by the assembler. Source code listing lines have several fields.

### Error field:

The error field is the first one on the line. It is placed there so that lines with error may be easily found. In general, assembly errors are indicated by a single letter in the error field on the line the error occurred on. If a line exhibits multiple errors, then several letters will appear there. One such error is shown in the sample listing indicating that a "VALUE" error occurred. This is because that line is attempting to load the eight-bit accumulator with a sixteen-bit value.

### Address field:

The address field generally indicates the address of any object code bytes which are listed on that line.

### Object field:

The object field generally indicates any object code bytes which were generated by the current line. It may also contain a 16-bit value preceded by an equal sign. This indicates the value of some expression which was evaluated on the line (for use in conditional directives, or which a symbol is equated to).

### Sequence field:

The sequence field indicates the line number of the current source line. If a macro is called on this line, the sequence field is followed by a `+` sign. If the line was generated by a macro, then the sequence field is followed by a single letter from `A`-`Z`. This letter indicates the depth of macro expansion generating the current line.

### Source Statement Field:

The source statement field contains the verbatim source code for the current line. No beatification is performed. Tabs are displayed normally because the sequence field starts on a tab stop.


## Assembler Directives

(As long as they are unique, most directives are also accepted abbreviated to 3 characters or more, e.g. `.NMLIST` = `.NMLIS` = `.NMLI` = `.NML`.)

### Listing Control Directives

#### `.NAME`/`.TITLE` *text*

The `.NAME` directive is used to inform the assembler of the name of the code being assembled. When the `.NAME` directive is encountered, all text following the `.NAME` directive is copied to a buffer and is printed on each page header. The source line containing the `.NAME` directive is not listed. If the name is too long. it is truncated.

#### `.SUBTTL` *text*

The `.SUBTTL` directive is used to inform the assembler of a subtitle for the current listing pages. When the `.SUBTTL` directive is encountered. all text following the `.SUBTTL` directive is copied to a buffer and is printed on each page header. The source line containing the `.SUBTTL` directive is not listed. If the name is too long. it is truncated.

#### `.PAGE`/`.PAG`

The `.PAGE` directive forces the listing file to the top of a next page if it is not currently there.

#### `.SKIP`/`.SKI`/`.SPACE` &lt;*optional expression*&gt;

The `.SKIP` directives are used to insert blank lines into the listing. If the `.SKIP` directive is followed by a number, that many blank lines are inserted.

#### `.FORMLN` *expression*

The `.FORMLN` directive sets the number of lines per page. It controls how many lines are generated between page headers. The actual number of lines per page generated is the value specified by `.FORMLN` plus six. If the expression evaluates to zero, then page headers are inhibited. Other unreasonable values generate an error.

#### `.LIST`/`.NLIST`

These directives toggle a switch controlling whether listing output is enabled. Lines which generate errors override this setting. This switch is also overridden for the symbol table and cross reference outputs.

#### `.CLIST`/`.NCLIST`

These directives control whether lines of conditional assembly code, which are not truly being assembled, are listed or not. Normally the assembler lists such lines.

#### `.MLIST`/`.NMLIST`/`.BLIST`

These directives control how macro expansion lines are listed. `.MLIST` (the default setting) lists all macro expansion lines. `.NMLlST` inhibits all macro expansion lines. `.BLIST` lists all macro expansions which cause object code to be generated.

#### `.GEN`/`.NOGEN`

Sometimes, a line of source code generates more bytes of object code than can fit on a single listing line. In this case, such bytes are listed on as many additional lines as neccesary. `.NOGEN` causes these additional lines to be inhibited. `.GEN` simply reenables them.

### Input Control Directives

#### `.INCLUDE` *filename*

The include file is used to combine files within the assembly. Essentially, the assembler substitutes the entire contents of the named source file for the `.INCLUDE` statement. Note that the assembler forces a convention that all source files end in `.src`. If the filename does not end in `.src`, the assembler will append it to the filename before attempting to open the file.

Be careful not to create circular linkages with this directive. This will result in ridiculously long assembly times.

#### `.END`

The `.END` directive terminates the assembly process and forces the assembler to ignore all further source lines.


### Core Generation Directives

#### `.WORD`/`.WOR`

The `.WORD` directive accepts a series of comma terminated expressions as arguments. Each argument is evaluated in order, and two bytes of object code are generated for each argument. The bytes are created in the usual low byte/high byte format, but are listed as 16-bit values.

#### `.DBYTE`

The `.DBYTE` directive is just like the `.WORD` directive except the the bytes are created in high byte/low byte format, and each byte is listed individually in the listing.

#### `.BYTE`/`.BYT`

The `.BYTE` directive also accepts a series of comma-terminated arguments. Each argument may contain either a normal byte valued expression resulting in a single byte of object code or a quoted string. In the byte directive, quoted strings must be enclosed in matching sets of single or double quotes. All characters between the matching quotes are treated as a literal and create one byte each.

### Macro Directives

#### `.MACRO` *dummy1, dummy2, ....dummyN*/`.ENDM`

...

### Repeat Directives

#### `.ENDR`

The `.ENDR` directive is used to mark the end of a section of code which is being using in a repeat directive.

#### `.REPT` *expression*

The `.REPT` directive is the simplest repeat directive. It is used to create several sections of code which are identical. It accepts a single expression as its argument. That expression controls the number of times the body of repeat code is repeated.

For example, the following code causes the line with the `.BYTE` statement to be repeated 5 times resulting in twenty bytes of object code being generated.

       .REPT 5
       .BYTE 1,2,3,4
       .ENDR

#### `.IRP` *dummy_argument, &lt;O-N optional arguments&gt;*

The `.IRP` directive is used to define a temporary macro with a single dummy argument, then call it a variable number of times with a predefined set of arguments. The first argument to the `.IRP` directive is the dummy argument used in the body of the macro definition. Each remaining argument causes the body of the `.IRP` macro to be expanded once with that argument substituted for the dummy argument.

For example, the following .IRP

       .IRP %DUMMY,THIS,IS,A,TEST
       .BYTE "%DUMMY",0
       .ENDR

generates the following code:

       .BYTE "THIS",0
       .BYTE "IS",0
       .BYTE "A",0
       .BYTE "TEST",0

#### `.IRPC` *dummy-argument, substitution-string*

`.IRPC` is a macro similar to `.IRP` in nature. Instead of accepting a series of arguments to be iteratively substituted, it accepts one argument (after the dummy argument). During each iteration of the loop, one character from the argument is substituted for the dummy argument.

For example, the following `.IRPC`

       .IRPC %DUMMY,ABC
       .BYTE "%DUMMY",$%DUMMY%DUMMY
       .ENDR

Generates the following code:

       .BYTE "A",$AA
       .BYTE "B",$BB
       .BYTE "C",$CC

Because all repeat directives are actually special case macros, they can be nested to any depth. The use of angle brackets to pass unusual arguments is also supported. See the section on MACROS for additional information.

### Conditional Directives

Conditional directives are a powerful means of controlling the assembler. They allow intelligent selection between sets of source code based on several types of conditions including the numeric value of expressions, whether symbols are defined, whether strings are blank, and the identicality of strings.

Here is an example of a piece conditional source code.

       .IFE SYMBOL
       lda #0     ; this line is assembled if·SYMBOL =0
       .ELSE
       lda #1     ; this line is assembled if SYMBOL <> 0
       .ELSE
       lda #0     ; this line is assembled if SYMBOL := 0
       .ENDIF

The main features of a conditional are the conditional directive itself and the `.ENDIF` directive terminating the range of the conditional.

In between these two lines is the conditional body. Normally the conditional body is assembled if the question the conditional directive asks is true. The `.ELSE` directive may be used to toggle the relative "TRUTH" of the conditional assembly thereby allowing the conditional to select between sections of source code to be assembled. All parts of the conditional other than the `.ENDIF` and the CONDITIONAL line itself are optional.

The use of undefined symbols in the expression for the conditional results in an error, (except for `.IFDEF`) and the conditional makes a choice as to whether to evaluate true or false.

There are several numeric conditionals. Each of these accepts a single expression as its argument. Numeric evaluation is considered to be a 16-bit two's complement.


`.IFE` expression evaluates true if expression is 0.
`.IFN` expression evaluates true if expression <> 0
`.IFGE` expression evaluates true if expression is >= 0.
`.IFGT` expression evaluates true if expression is > 0.
`.IFLT` expression evaluates true if expression is < 0.
`.IFLE` expression evaluates true if expression is =< 0.

There are several textual conditionals. These are essentially useless if used alone. However, when combined with macros they can make many tasks easier. They can, for example, be used to detect the presence or absence of arguments.

#### `.IFB`/`.IFNB` *&lt;string&gt;*

The `.IFB` directive evaluates true if its argument is found to be blank. Because of its nature, it is strongly recommended that this argument be delimited by the enclosing angle brackets as discussed in the section describing MACROS. `.IFNB` is simply the inverse of `.IFB`.

#### `.IFIDN`/`.IFNIDN` *<string1>,<string2>*

`.IFIDN` evaluates true if the two argument strings are identical. This operation is case sensitive. `.IFNIDN` evaluates true if they are not identical.

#### `.IFDEF``.IFNDEF` *<symbol_name>*

`.IFDEF` evaluates true if the argument is both a legal symbol name, and has been previously defined in the source file. `.IFNDEF` evaluates true if the argument is either not a legal symbol name, or has not previously been defined.

### Sections

* `.ASECT` [`LOC=`] *symbol*
* `.SECT` [`ABS,LOC=`] *symbol*

### Miscellaneous Directives

#### `.LOCAL`

The `.LOCAL` directive is used to delimit the range of local labels. It enables this operation without forcing the unneccesary act of thinking up yet another label name.

#### `.MESSG` *<text>*

The `.MESSG` forces the following text to be echoed out the error channel during pass2. Its primary use is inside of conditionals to present error messages for code overflow, etc.

#### `.RMB` *<number>*

(Reserve Memory Byte) `.RMB` is functionally identical to `*=*+`. It advances the program counter without generating object code. *<number>* specifies the number of bytes to reserve.


* `.RADIX`: set default radix for all numbers without a prefix
* `.AORG`: ???


## TODO

* Document assembler directives
* Convert K&R -&gt; C90
* Fix LLVM/GCC warnings
* Handle UNIX patch separators correctly


## Authors

**Commodore 6502ASM** was written by Fred Bowen in 1989. This repository is maintained by Michael Steil <mist64@mac.com>.
