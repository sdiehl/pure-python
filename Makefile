all: 
	cython pure.pyx
	gcc -O2 -fPIC -c pure.c -I/usr/include/python2.6 -lpure -lm -lint
	gcc -shared pure.o -o pure.so -lm -lpure

clean:
	rm -f *.so
	rm -f *.o
	rm -f *.pyc
