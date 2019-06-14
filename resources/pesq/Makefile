DESTDIR =
PREFIX = /usr
BINDIR = /bin

all : build

build : bin/pesq

install : build
	install -dm755 bin/pesq "$(DESTDIR)$(PREFIX)$(BINDIR)"

distclean : clean

clean :
	rm -rf bin/
	rm -rf source/*.gch

bin :
	mkdir bin

bin/pesq : bin
	$(CC) $(CFLAGS) -o $@ source/*.c -lm

