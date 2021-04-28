#CFLAGS=-Wall -Werror -g
SDIR=.
ODIR=build
EXECUTABLE=$(ODIR)/4502asm

_OBJS = asm.o direct1.o direct2.o express.o help.o line.o macrodef.o opcode.o outline.o pass1.o pass2.o symbol.o

_HEADERS = asm.h template.h

OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))
HEADERS = $(patsubst %,$(SDIR)/%,$(_HEADERS))

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJS) $(HEADERS)
	$(CC) -o $(EXECUTABLE) $(OBJS) $(LDFLAGS)

$(ODIR)/%.o: $(SDIR)/%.c
	@mkdir -p $$(dirname $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(ODIR)
