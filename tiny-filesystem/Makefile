TARGET  = tinyFsDemo
CC      = gcc
CCFLAGS = -g -Wall -Werror
SOURCES = $(wildcard *.c)
INCLUDE = $(wildcard *.h)
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	touch test.txt
	$(CC) -o $(TARGET) $(OBJECTS)

$(OBJECTS): $(SOURCES)
	$(CC) -c $(CCFLAGS) $(SOURCES)

clean:
	-rm -f $(TARGET) $(OBJECTS) test.txt