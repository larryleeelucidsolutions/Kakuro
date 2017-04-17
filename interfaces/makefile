includes=-I../includes -I..

mods=../includes/set.d ../includes/matrix.d

libs=../kakuro/libkakuro.a

all: kakuro-cmd kakuro-file

kakuro-cmd:
	dmd kakuro-cmd.d $(includes) $(mods) $(libs)

kakuro-file:
	dmd kakuro-file.d $(includes) $(mods) $(libs)

install: all
	cp kakuro-cmd /usr/local/bin/

	cp kakuro-file /usr/local/bin/

uninstall: 
	rm -f /usr/local/bin/kakuro-cmd

	rm -f /usr/local/bin/kakuro-file

clean:
	rm -f {*.{o,html},kakuro-cmd,kakuro-file}
