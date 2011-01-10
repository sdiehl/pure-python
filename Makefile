TARGET  := cpure.so
PYSRC  := cpure.pyx
CSRC    := ${PYSRC:.pyx=.c} 
OBJS   := ${PYSRC:.pyx=.o} 

PYTHONPATH = `python -c "from distutils.sysconfig import get_python_inc; print get_python_inc()"`

CCFLAGS = -O3 -Wall -fPIC -I$(PYTHONPATH)
LDFLAGS = -shared
LIBS    = -lpure
#CC	= clang

.PHONY: all clean distclean 
all:: ${TARGET} 

distclean:: clean

${TARGET}: ${OBJS} 
	${CC} ${LDFLAGS} -o $@ $^ ${LIBS} 

${OBJS}: %.o: %.c ${CSRC}
	${CC} ${CCFLAGS} -o $@ -c $< 

${CSRC}: $(PYSRC)
	cython $<

clean:
	-rm -f *~ ${CSRC} ${OBJS} ${TARGET} *.pyc *.pyo

check:
	python -m tests
