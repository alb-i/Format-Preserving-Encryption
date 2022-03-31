MYCFLAGS = -O2 -Wall -fPIC $(CFLAGS)
SO_LINKS = -lm -lcrypto

LIB = libfpe.a libfpe.so
EXAMPLE_SRC = example.c
EXAMPLE_EXE = example
OBJS = src/ff1.o src/ff3.o src/fpe_locl.o

all: $(LIB) $(EXAMPLE_EXE)

libfpe.a: $(OBJS)
	ar rcs $@ $(OBJS)

libfpe.so: $(OBJS)
	gcc -shared -fPIC -Wl,-install_name,libfpe.so $(OBJS) $(LDFLAGS) $(SO_LINKS) -o $@

.PHONY = all clean

src/ff1.o: src/ff1.c
	gcc $(MYCFLAGS) -c src/ff1.c -o $@

src/ff3.o: src/ff3.c
	gcc $(MYCFLAGS) -c src/ff3.c -o $@

src/fpe_locl.o: src/fpe_locl.c
	gcc $(MYCFLAGS) -c src/fpe_locl.c -o $@

$(EXAMPLE_EXE): $(EXAMPLE_SRC) $(LIB)
	gcc '-Wl,-rpath,$$$$ORIGIN' $(EXAMPLE_SRC) $(LDFLAGS) $(CFLAGS) -L. -lfpe -Isrc -O2 -o $@

clean:
	rm $(OBJS)

