TARGET  := pure.so
PYSRC  := pure.pyx
CSRC    := ${PYSRC:.pyx=.c} 
OBJS   := ${PYSRC:.pyx=.o} 

#PYTHONPATH = /usr/include/python2.6
PYTHONPATH = /usr/include/python2.7

CCFLAGS = -O3 -Wall -fPIC -I$(PYTHONPATH)
LDFLAGS = -shared
LIBS    = -lpure
#CC		= clang

.PHONY: all clean distclean 
all:: ${TARGET} 

${TARGET}: ${OBJS} 
	${CC} ${LDFLAGS} -o $@ $^ ${LIBS} 

${OBJS}: %.o: %.c ${CSRC}
	${CC} ${CCFLAGS} -o $@ -c $< 

${CSRC}: $(PYSRC)
	cython $<

clean:
	-rm -f *~ ${CSRC} ${OBJS} ${TARGET} *.pyc *.pyo

distclean:: clean
