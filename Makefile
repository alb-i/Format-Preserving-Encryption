MYCFLAGS = -O2 -Wall -fPIC $(CFLAGS)
SO_LINKS = -lm -lcrypto

LIB = libfpe.a libfpe.so
EXAMPLE_SRC = example.c
EXAMPLE_EXE = example
BATCH_FF3_SRC = batch-ff3.c
BATCH_FF3_EXE = batch-ff3
OBJS = src/ff1.o src/ff3.o src/fpe_locl.o

all: $(LIB) $(EXAMPLE_EXE) $(BATCH_FF3_EXE)

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

$(BATCH_FF3_EXE): $(BATCH_FF3_SRC) $(LIB)
	gcc '-Wl,-rpath,$$$$ORIGIN' $(BATCH_FF3_SRC) $(LDFLAGS) $(CFLAGS) -L. -lfpe -Isrc -O2 -o $@


clean:
	rm $(OBJS)

