
prefix=/usr/local/

lib=$(prefix)lib/

include=$(prefix)include/

all: libkakuro interfaces

libkakuro:
	$(MAKE) -e -C kakuro

test: libkakuro
	dmd test.d -unittest -Iincludes includes/matrix.d includes/math.d includes/set.d kakuro/cons.d kakuro/seqs.d kakuro/libkakuro.a 

interfaces: libkakuro
	$(MAKE) -e -C interfaces

clean:
	rm -f test{,.o,.html}
	rm -f trace.{def,log}
	$(MAKE) -e -C kakuro clean
	$(MAKE) -e -C interfaces clean

install: libkakuro
	$(MAKE) -e -C interfaces install

uninstall:
	$(MAKE) -e -C interfaces uninstall
