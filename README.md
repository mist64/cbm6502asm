# Commodore 6502ASM

This is the source code of the 6502/65C02/65CE02 assembler developed and used by Commodore for the C65 project.

It aims to be compatible with the Boston System Office [CR6502/11 cross-assembler](https://github.com/TYMCOM-X/169273.tape/blob/abc68e373db6be0104efe986d23624462ef691b9/*6news/ca6502.doc), which Commodore had used to build all its source after 1984.

It is also highly compatible with Commodore's HCD65XX assembler that ran on the C128 (released as part of the [C128 Devpak](http://www.zimmers.net/anonftp/pub/cbm/demodisks/c128/)) as well as Commodore's earlier "[Resident Assembler](https://github.com/mist64/kernalemu/)" (PET, C64, CBM2, TED, C128).

Because of its heritage, it is mostly compatible with older Commodore source code, like the [cbmsrc](https://github.com/mist64/cbmsrc) collection.

This source is based on version "B0.0", dated 1989-06-14 from `4502-asm-for-pc.img` of the [Dennis Jarvis collection](http://6502.org/users/sjgray/dj/) and has been slightly updated:
* A UNIX-style Makefile has been added.
* The whole source has been linted into a more modern coding style.
* Some compiler warnings have been fixed.
* The behavior has been changed to default to lower case extensions.
* `.IF` has been added for BSO compatibility.
* The macro-within-include bug has been fixed (see [serlib.zip](http://www.zimmers.net/anonftp/pub/cbm/src/drives/serlib.zip) for an example run before the fix).


## Table of Contents

* [Usage](#usage)
* [Case Sensitivity](#case-sensitivity)
* [Constants](#constants)
* [Input File Format](#input-file-format)
* [Symbols and Labels](#symbols-and-labels)
* [Assigning Values to Symbols](#assigning-values-to-symbols)
* [Expressions](#expressions)
* [Macros](#macros)
* [Listing Format](#listing-format)
* [Assembler Directives](#assembler-directives)
* [Error Reporting](#error-reporting)
* [TODO](#todo)
* [Authors](#authors)

Since this assembler is backwards compatible with Commodore's HCD65 assembler, much of this documentation has been adapted from chapter 2 of the [C128 Developers Package for Commodore 6502 Development](http://www.zimmers.net/anonftp/pub/cbm/schematics/computers/c128/servicemanuals/C128_Developers_Package_for_Commodore_6502_Development_(1987_Oct).pdf)  service manual.

## Usage

The assembler command line consists of these file names and switches:

    C65> [object],[listing]=source[,source]...[,source][/switch]...[/switch]

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


## Case Sensitivity

The assembler is case insensitive for all non-quoted strings. This includes symbol names, label names, macro names, opcodes, and directives. The list file shows the source statements in the case they are presented to the assembler in. The symbol table and cross references list all symbols in the same case. Subtitles, program names, and other uniquely textual items are not case sensitive. However, on systems with case sensitive filesystems, `.INCLUDE` filenames must be specified in the correct case.


## Constants

Internally, the assembler uses 16-bit values to represent constants. Constants may be expressed in one of four radices or may be created using literal strings.

### Hexadecimal Constants

Hexadecimal constants are represented by one to four hexadecimal characters following a dollar sign (i.e., $1A7F).

### Decimal Constants

Decimal constants are represented by one to five decimal digits. No leading radix character is needed. (The `.RADIX` directive changes the radix of all constants without a prefix.)

### Octal Constants

Octal constants are represented by an octal number preceded by the "@” symbol. (i.e., @17777).

### Binary Constants

Binary constants are represented by a binary number preceded by the "%” symbol. (i.e., %01010100111).

### Literal Constants

Literal constants are represented by one or two ASCII or PETSCII characters enclosed in matching single quote characters. In certain situations, only the first single quote is neccesary. Certain differences exist in the way the `.BYTE` directive handles quoted strings. See that directive’s explanation. In the case where two literal characters are enclosed in quotes, the assembler places the first character in the low order field in the resulting 16-bit value.


## Input File Format

There are four fields recognized by the assembler. Each is optional and they typically are delimited by spaces or tabs.

       Label_Field Operator_Field Argument_Field Comment_Field

Comment lines are marked with a semicolon as the first non-white character (white characters are spaces and tabs). Any characters appearing after a semicolon (except a semicolon that appears in quotes) are considered to be comments and are ignored.

Any text starting in the first column which is non blank and is not a comment is considered to be a label or symbol except in the case where there is a macro directive on that line. In that case the text is considered to be the macro name.

The text in the second field defines how the assembler will interpret that line. Mnemonics, assembler directives, and macro calls are all placed here.

The third field generally contains arguments to the second field. In cases where the operation does not expect arguments, the third field is considered to be a comment field.

Anything after the third field is considered to be a comment.


## Symbols and Labels

Three type of symbols are supported by the assembler.

* Global symbols
* Global labels
* Local labels

Global symbols and labels represent 16-bit values. A symbol name is a string alphanumeric characters. None of the characters can be the characters which the assembler recognizes as an expression delimiter ( i.e.. quote marks, spaces, expression operators, radix operators, etc ). In addition, the first character in a symbol name cannot be a digit from 0-9, as those characters are indicative of local labels.

Global symbol or global label names may be of any length, although only the first 32 characters are significant and all other characters are truncated for cross reference and symbol table purposes.

Examples of valid symbols:

* `the_routine_is_here`
* `a3485734583488`
* `periods.are.legal`
* `this_symbol_soJong_thatJtJs_the_same_as_the_next`
* `this_symbol_soJong_thatJtJs_the_same_as_the_previous`

Examples of illegal symbols:

* `here+nop` ; this is an expression with two symbols
* `123ksdhjfks` ; this starts with a digit

NOTE: The asterisk `*` is a special symbol. It represents the current program counter. It may be assigned a value and it may be evaluated.

Global labels differ from global symbols in that the symbols can be redefined many times during assembly. Labels can only be defined once.

A symbol definition must be made explicitly using the equals sign (`=`). Any time a potential symbol appears in the label field, and is not explicitly made a symbol using the equal sign, it becomes a label. Further attempts to define it result in assembly error generation.

Local labels take the form of one to three decimal digits with the value of 1-255 immediately followed by a dollar sign.

Examples of local labels:

       100$    ; this is legal
       001$    ; this is the same as the next
       1$      ; this is the same as the previous
       999$    ; this is illegal (1-255).


The range over which a local label is defined is delimited by two things:

1) global labels
2) the `.LOCAL` directive.

Example:

       test    jsr 10$  ; ok
       10$     bne 20$  ; ok
       20$     bpl 30$  ; not ok, 30$ not defined here
       test2   nop      ; the label here delimits the 30$
       30$     bne 10$  ; ok, this 10$ is the one below.
       10$     nop      ; ok, this is a different 10$ than
                        ; the one on the second line.
               .local 
               jmp 30$  ; not ok, the .local directive limits
                        ; the range of the 30$


## Assigning Values to Symbols

Symbols may given a value in two ways.

### Appearance in the labei field.

A symbol which appears in the label field becomes a label except in 2 cases:

1) The symbol is being assigned a value using the `=` sign, (see below)
2) The symbol appears on a line with a `.MACRO` directive. In this case the symbol becomes the name of macro.

### Explicit assignment using the equals sign

A symbol may be assigned a value using the equal sign. For example:

       nine = $09 ; assign the hex value 9 to the symbol ”nine”


## Expressions

Expression processing in the assembler accepts a large number of operators. Expressions are evaluated left to right except in the following cases:

Highest Priority operators:

       Unary +   truth operator
       Unary -   two’s complement operator
       !N        one’s complement operator (logical not)
       <         low byte operator (returns low byte of value)
       >         high byte operator (returns high byte of value)

Second Priority operators:

       *         16 bit multiply, returns low order 16-bit result
       !.        logical AND
       !+        logical OR
       !X        logical Exclusive OR

Lowest Priority operators:

       Binary +  16 bit addition, carry discarded
       Binary -  16 bit subtraction, borrow ignored.

For Example:

       $1234    = $1234
       >$1234   = $0012
       >$1234+1 = $0013
       1+>$1234 = $0013
       5-1-1    = $0003
       -1       = $FFFF
       >-1      = $00FF
       !N$000F  = $FFF0


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

The `.MACRO` and `.ENDM` directives are extensively discussed in the [Macros](#macros) section.

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

Because all repeat directives are actually special case macros, they can be nested to any depth. The use of angle brackets to pass unusual arguments is also supported. See the section on [Macros](#macros) for additional information.

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

* `.IFE` expression evaluates true if expression is 0.
* `.IFN`/`.IF` expression evaluates true if expression &lt;&gt; 0
* `.IFGE` expression evaluates true if expression is &gt;= 0.
* `.IFGT` expression evaluates true if expression is &gt; 0.
* `.IFLT` expression evaluates true if expression is &lt; 0.
* `.IFLE` expression evaluates true if expression is =&lt; 0.

There are several textual conditionals. These are essentially useless if used alone. However, when combined with macros they can make many tasks easier. They can, for example, be used to detect the presence or absence of arguments.

#### `.IFB`/`.IFNB` *&lt;string&gt;*

The `.IFB` directive evaluates true if its argument is found to be blank. Because of its nature, it is strongly recommended that this argument be delimited by the enclosing angle brackets as discussed in the [Macros](#macros) section. `.IFNB` is simply the inverse of `.IFB`.

#### `.IFIDN`/`.IFNIDN` *&lt;string1&gt;,&lt;string2&gt;*

`.IFIDN` evaluates true if the two argument strings are identical. This operation is case sensitive. `.IFNIDN` evaluates true if they are not identical.

#### `.IFDEF`/`.IFNDEF` *&lt;symbol_name&gt;*

`.IFDEF` evaluates true if the argument is both a legal symbol name, and has been previously defined in the source file. `.IFNDEF` evaluates true if the argument is either not a legal symbol name, or has not previously been defined.

### Miscellaneous Directives

#### `.LOCAL`

The `.LOCAL` directive is used to delimit the range of local labels. It enables this operation without forcing the unneccesary act of thinking up yet another label name.

#### `.MESSG` *&lt;text&gt;*

The `.MESSG` forces the following text to be echoed out the error channel during pass2. Its primary use is inside of conditionals to present error messages for code overflow, etc.

#### `.RMB` *&lt;number&gt;*

(Reserve Memory Byte) `.RMB` is functionally identical to `*=*+`. It advances the program counter without generating object code. *&lt;number&gt;* specifies the number of bytes to reserve.

#### `.RADIX` *&lt;number&gt;*

This directive sets the default radix for all constants without a leading radix character.

#### `.AORG` *&lt;number&gt;*

The `.AORG` directive is a synonym to `*=`. It sets the program counter to the specified argument

#### `.SECT` *name* [`,ABS,LOC=` *symbol*]
#### `.ASECT` *name* [`,LOC=` *symbol*]

The `.SECT` and `.ASECT` directives either declare or switch to a section. You can declare a section like this:

       .ASECT SEC_MAIN,LOC=$1000

This creates an entry in the symbol table for the section `SEC_MAIN`, and sets it to $1000. It also sets the program counter to $1000.

You can switch between sections like this:

       .ASECT SEC_MAIN

The value of the current section will be updated with the current program counter, and the program counter will be set to the value of the new section.

The default section `A` exists for every program.

*These directives do not seem to work right.*


## Error Reporting

There are three types of errors reported by the assembler. Errors are issued to both the error channel and to the listing.

### Fatal Errors

Fatal errors prevent the assembler from continuing the assembly. These include running out of macro expansion space, and read errors from disk in the middle of a file. Fatal errors, which result in assembly termination, are accompanied by explanatory error messages.

### System Errors

System errors include inability to find an include file, to properly access the cross reference file, and other such non fatal errors.

### Assembly Errors

Assembly errors are those related to the source file content. They can usually be associated with a single erroneous line of source code. As such, assembly errors are reported in the listing on the same line with the offending source. If the error channel is different from the listing channel, then the offending line is also echoed to the error channel.

Assembly errors occur for a variety of reasons. Each one has a specific error code printed in the first few columns of the listing output. The error codes and their definitions are listed below.

* `A`: Address error. Indicates bad address valued expression was evaluated. May indicate branch out of range.
* `B`: Balance error. Quotes, or angle brackets are mispaired on this line.
* `E`: Expression error. Invalid syntax in an expression. This error is more serious than a syntax error. Occurs when invalid expressions are used in critical places (like * = undefined_symbol).
* `F`: Field error. Something is missing on the line.
* `J`: Indicates that the address space is filled and that the resulting object code has wrapped from $FFFF to $0000 and a byte was created at $0000.
* `M`: Multiply-defined symbol. A symbol is defined more than once (where this is illegal). All but the first definition are ignored.
* `N`: Nesting error. Unexpected `.ELSE`, `.ENDIF`, `.ENDR`, or `.ENDM` detected.
* `O`: Undefined opcode or macro call used on this line.
* `P`: Phase error. Indicates the value of label was different in pass 2 than in pass 1. This may indicate a source file ( disk ) problem or some sort of illegal forward reference. The assembler is confused.
* `Q`: Questionable syntax. Indicates a syntax error which the assembler has resolved by some (probably incorrect) assumption.
* `S`: Syntax error. Generated for all sorts of syntactical errors.
* `U`: Undefined symbol. The assembler attempted to evaluate an expression which has an undefined symbol in it.
* `V`: Value error. An operand value was out of range. Typically generated when a 16-bit value is placed in an 8-bit field. Also flags attempts to branch out of range.
* `W`: Wasted byte warning. Generated when the assembler is forced to use an absolute addressing mode where a zero page addressing mode would suffice. This warning is typically created by forward references.
* `Z`: Division by zero error. Generated when an expression requests the assembler to divide by zero.
* `@`: Symbol table overflow. The symbol table is full and a symbol on this line cannot be written to the symbol table. All references to this symbol will result in undefined symbol errors.
* `?`: Internal error checking has conflicting results. This error occurs when the assembler detects an error which by design, should notoccur. This is indicative of a bug; however chances are that some construct on the line is questionable. This error can usually be eliminated by rearranging the line.
* `*`: Too many error codes were generated for this line for the assembler to list them all.


## TODO

* Fix LLVM/GCC warnings
* Handle UNIX path separators correctly


## Authors

**Commodore 6502ASM** was written by Fred Bowen in 1989. This repository is maintained by Michael Steil, <mist64@mac.com>.
