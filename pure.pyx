cimport pure
cimport cpython
from libc.stdlib cimport *

# This module only works with Python 2.7
# I designed this after working with rpy2's Cython wrapper.

class IManager:
    # Interpreter manager - a singleton / borg
    current_interp = None

    def __cinit__(self):
        self.__dict__ = self.__shared_state

    def add(self, interp):
        self.current_interp = interp

    def get(self):
        if self.current_interp:
            return self.current_interp
        else:
            raise Exception('No active interpreter')

    @classmethod
    def exists(self):
        return not self.current_interp

    @classmethod
    def active(self):
        return self()

cdef class PureEnv:
    cdef pure_interp *_interp
    cpdef list locals
    cdef char **argv

    def __cinit__(self):
        # This is called whenever a worker is spawned, it must be
        # light and fast.
        print "Creating interpreter instance."

        args = ['--noprelude']

        cdef char *xp
        cdef char *xps[5]
        for i in range(0,len(args)):
            #xp = <char *>malloc(len(args[i]) * sizeof(char))
            #xps[i] = <char *>malloc( (len(args[i])+2) * sizeof( char* ) )
            #xp = '--noprelude'
            xp = 'h'
            strcpy(xps[i],xp)

        self._interp = pure.pure_create_interp(len(args),xps)
        print 'Created succesfully!'
        #try:
        #    print 'Created succesfully!'
        #finally:
        #    pass
        #    free(self.argv)

        if self._interp is NULL:
            cpython.PyErr_NoMemory()

        # PureSymbol fails if this not here
        self.locals = []
        im = IManager.active()
        im.add(self)

        print 'Exited'

    def __dealloc__(self):
        pass

    cpdef eval(self, s):
        cdef pure_expr *y
        y = pure.pure_eval(s)
        if y == NULL:
            print "Could not evaluate:", s
        else:
            return PureExpr().se(y)

    cpdef cmd(self, s):
        print pure.pure_evalcmd(s)

    def using(self, lib):
        self.eval("using %s" % lib)
        for sym in self.locals:
            sym.update()

    def compile_interp(self, fnp=0):
        print 'JIT compiling symbols.'
        pure.pure_interp_compile(self._interp,fnp)

cdef class PureExpr:
    cdef pure_expr *_expr
    cpdef int _tag
    cpdef int _refc
    _type = None
    cdef PureEnv _interp

    def __cinit__(self):
        pass

    cdef se(self, pure_expr *ex):
        self._expr = ex
        self._tag = ex.tag
        return self

    @property
    def interp(self):
        return self._interp

    @property
    def tag(self):
        self._tag = self._expr.tag
        return self._tag

    def refresh(self):
        self._expr = pure.eval(self._expr)

    @property
    def refc(self):
        self._refc = self._expr.refc
        return self._refc

    @property
    def type(self):
        return self._type

    def __del__(self):
        pure.pure_free(self._expr)

    def __repr__(self):
        return pure.str(self._expr)

    def __call__(self,*args):
        cdef pure_expr *xp
        #TODO, why did I set this to 10?
        cdef pure_expr *xps[10]

        for i in range(0,len(args)):
            xp = g(args[i])
            pure.pure_ref(xp)
            xps[i] = xp

        cdef pure_expr *nexp
        pure.pure_ref(self._expr)
        nexp = pure.pure_appv(self._expr, len(args), xps)
        nex = (PureApp().se(nexp))
        nex.set_head(self)
        return nex

    #def __richcmp__(self, PureExpr other, int op):
    #    if op == 2:
    #        return (self.tag) == (other.tag)
    #    else:
    #        return False

    #cpdef __richcmp__(self, PureExpr other):
    #    return pure.same(self._expr, other._expr)

    #def __add__(self,other):
    #    return operator.add(self,other)

    #def __neg__(self):
    #    return operator.neg(self)

    #def __sub__(self,other):
    #    return operator.sub(self,other)

    #def __mul__(self,other):
    #    return operator.mul(self,other)

    #def __div__(self,other):
    #    return operator.div(self,other)

cdef class PureApp(PureExpr):
    _type = 'app'
    cdef PureExpr _head
    cdef pure_expr _rebuild
    cdef char* _sym

    def __invert__(self):
        return PureQuotedSymbol(self._sym)

    def set_head(self, head):
        self._head = head

    def get_head(self):
        return self._head

    def update(self):
        pass

cdef class PureSymbol(PureExpr):
    _type = 'symbol'
    cdef char* _sym
    cdef public _psym

    def __cinit__(self,sym):
       if not IManager.exists():
           print 'No active interpreter'
       else:
           self._sym = sym
           self._psym = sym
           self._expr = pure.pure_symbol(pure.pure_sym(sym))
           self._tag = self._expr.tag
           #self._interp = IManager.active().current_interp
           #self._interp.locals.append(self)

    def update(self):
       '''Called if the we need to change what the symbol refers to'''
       self._expr = pure.pure_symbol(pure.pure_sym(self._sym))
       self._tag = self._expr.tag

    def __invert__(self):
        return PureQuotedSymbol(self._sym)

cdef class PureQuotedSymbol(PureExpr):
    cdef char* _sym

    def __cinit__(self,sym):
       self._sym = sym
       self._expr = pure.pure_quoted_symbol(pure.pure_sym(sym))
       self._tag = self._expr.tag

cdef class PureClosure(PureSymbol):
    cdef public arity

cdef class PureRule(PureExpr):
    cdef char* _stmt
    cdef public _pstmt

    def __cinit__(self, lhs, rhs):
        if isinstance(lhs,type("")):
            slhs = lhs
        else:
            slhs = pure.str(g(lhs))

        if isinstance(rhs,type("")):
            srhs = rhs
        else:
            srhs = pure.str(g(rhs))

        stmt = "=".join([slhs,srhs])
        self._stmt = stmt
        self._pstmt = stmt

        if isinstance(lhs,PureApp):
            #print 'Changing head'
            #lhs.get_head().update()
            pass

    def __repr__(self):
        return self._stmt

cdef class PureInt(PureExpr):
    _type = 'int'
    number = None

    def __cinit__(self,i):
        if abs(i) > 2147483648:
            raise TypeError('Integer is larger than 32-bits.')
            return

        self._expr = pure.pure_int(i)
        self._tag = self._expr.tag

cdef class PureDouble(PureExpr):
    _type = 'double'
    number = None

    def __cinit__(self,i):
        self._expr = pure.pure_double(i)
        self._tag = self._expr.tag

cdef class PureList(PureExpr):
    _type = 'list'

    def __cinit__(self,*args):
        cdef pure_expr *xp
        cdef pure_expr *xps[10]
        for i in range(0,len(args)):
            xp = g(args[i])
            xps[i] = xp
        self._expr = pure.pure_listv(len(args),xps)

#    def __getitem__(a,b):
#        return operator.__getitem__(a,PureInt(b))
#
#    def __getslice__(a,b,c):
#        return operator.__getslice__(a,PureInt(b),PureInt(c))

cdef class PureTuple(PureExpr):
    _type = 'tuple'

    def __cinit__(self,*args):
        cdef pure_expr *xp
        cdef pure_expr *xps[10]
        for i in range(0,len(args)):
            xp = g(args[i])
            xps[i] = xp
        self._expr = pure.pure_tuplev(len(args),xps)

cdef class PureLevel(PureExpr):
    _type = 'level'
    cdef uint32_t _hash

    def __cinit__(self,rules):
        # I can't figure out how to use the locals command in the
        # public API so we'll just use the eval until I can
        # figure out a better way

        rls = '; '.join(rules)
        cmd = ' '.join(['__locals__ with', rls, 'end;'])
        self._expr = pure.pure_eval(cmd)
        self._hash = pure.hash(self._expr)

    def hash(self):
        return self._hash

cdef pure_expr *g(PureExpr obj):
    return obj._expr

def reduce_with_pure_rules(PureExpr level, PureExpr expr):
    '''Convert a Python list of strings into a dynamic local
    enviroment and pass reduce the given expression with it'''

    # Basically equivelent to
    # reduce_with expr __locals__ with rule1; rule2; end;

    cdef pure_expr *rexp
    rexp = pure.reduce(level._expr, expr._expr)
    return PureExpr().se(rexp)

def new_level():
    pure.pure_save()

def restore_level():
    pure.pure_restore()
