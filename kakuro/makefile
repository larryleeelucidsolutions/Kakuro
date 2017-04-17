
all: libkakuro

libkakuro:
	dmd -lib -oflibkakuro.a ../includes/set.d ../includes/array.d ../includes/math.d checks.d cons.d core.d seqs.d

clean:
	rm -f libkakuro.a
