CC = gcc
CFLAGS = -g -O0 -Wall -Wextra -Wunused

SRCDIR = ./src

SRCS_ =	main.c

EXECUTABLE = input_gen

SRCS = $(patsubst %,$(SRCDIR)/%,$(SRCS_))

OBJS = $(SRCS:.c=.o)

all:	$(EXECUTABLE)

$(EXECUTABLE): $(OBJS)
	@$(CC) $(CFLAGS) -o $(EXECUTABLE) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<  -o $@

.PHONY: clean

clean:
	@$(RM) $(SRCDIR)/*.o  *~ $(EXECUTABLE)
