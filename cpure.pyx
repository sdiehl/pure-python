cimport cpure
cimport cpython
from libc.stdlib cimport *

__all__ = ['PureInt', 'PureSymbol', 'PureLevel',
'PureExpr', 'PureDouble', 'PureClosure', 'reduce_with_pure_rules',
'new_level', 'restore_level', 'PureEnv']

cdef class PureEnv:
    """
    Wrapper for spawning and managing Pure interpreter instances.
    """
    cdef pure_interp *_interp
    cpdef list locals
    cdef char **argv

    def __cinit__(self):
        # This is called whenever a worker is spawned, it must be
        # light and fast.
        print "Creating interpreter instance ...",

        self._interp = cpure.pure_create_interp(0,NULL)

        if self._interp is NULL:
            cpython.PyErr_NoMemory()
            print 'FAIL'
            return

        # PureSymbol fails if this not here
        self.locals = []

        print 'SUCCESS'

    def __dealloc__(self):
        pass

    cpdef eval(self, s):
        """
        Evaluate a string in the active interpreter.
        """
        cdef pure_expr *y
        y = cpure.pure_eval(s)
        if y == NULL:
            print "Could not evaluate:", s
        else:
            return PureExpr().se(y)

    def using(self, lib):
        """
        Include a Pure library in this active interpreter.
        """
        self.eval("using %s" % lib)
        for sym in self.locals:
            sym.update()

    def compile_interp(self, fnp=0):
        """
        Force the active interpreter to JIT compile all toplevel
        symbols.
        """
        print 'JIT compiling symbols.'
        cpure.pure_interp_compile(self._interp,fnp)

cdef class PureExpr:
    """
    Base class for all derived Pure expressions wrappers.
    """
    cdef pure_expr *_expr
    cpdef int _tag
    _type = None
    cdef PureEnv _interp

    def __cinit__(self):
        pass

    cdef se(self, pure_expr *ex):
        """
        Bind Python object to pure_expr object.
        """
        self._expr = ex
        self._tag = ex.tag
        return self

    @property
    def interp(self):
        """
        Return the interpreter instance for this symbol.
        """
        return self._interp

    @property
    def tag(self):
        """
        Return the internal tag value from the pure_expr struct.
        """
        self._tag = self._expr.tag
        return self._tag

    @property
    def type(self):
        """
        Return the `type` attribute as overloaded by child
        classes.
        """
        return self._type

    def __del__(self):
        """
        Bind the Python garbage collection to the pure_free
        function on the pure_expr object.
        """
        cpure.pure_free(self._expr)

    def __repr__(self):
        """
        Return a string representation of the pure_expr object as
        given by the `str` function in Pure.
        """
        return cpure.str(self._expr)

    def __call__(self,*args):
        """
        Apply the given arguments to symbol on the right hand
        side. Roughly Equivalent to the `$ arg1 arg2 ...`
        syntax in Pure.
        """
        cdef pure_expr *xp
        #TODO, why did I set this to 10?
        cdef pure_expr *xps[10]

        for i in range(0,len(args)):
            xp = g(args[i])
            cpure.pure_ref(xp)
            xps[i] = xp

        cdef pure_expr *nexp
        cpure.pure_ref(self._expr)
        nexp = cpure.pure_appv(self._expr, len(args), xps)
        nex = (PureApp().se(nexp))
        nex.set_head(self)
        return nex

    #def __richcmp__(self, PureExpr other, int op):
    #    if op == 2:
    #        return (self.tag) == (other.tag)
    #    else:
    #        return False

    #cpdef __richcmp__(self, PureExpr other):
    #    return cpure.same(self._expr, other._expr)

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
    """
    A Pure function application.
    """
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
    """
    Generic Pure symbol specified by alphanumeric characters.
    """
    _type = 'symbol'
    cdef char* _sym
    cdef public _psym

    def __cinit__(self,sym):
       self._sym = sym
       self._psym = sym
       self._expr = cpure.pure_symbol(cpure.pure_sym(sym))
       self._tag = self._expr.tag

    def update(self):
       '''Called if the we need to change what the symbol refers to'''
       self._expr = cpure.pure_symbol(cpure.pure_sym(self._sym))
       self._tag = self._expr.tag

    def __invert__(self):
        return PureQuotedSymbol(self._sym)

cdef class PureQuotedSymbol(PureExpr):
    """
    A quoted PureSymbol.
    """
    cdef char* _sym

    def __cinit__(self,sym):
       self._sym = sym
       self._expr = cpure.pure_quoted_symbol(cpure.pure_sym(sym))
       self._tag = self._expr.tag

cdef class PureClosure(PureSymbol):
    """
    A Pure closure, i.e. a reference to callable object.
    """
    cdef public arity

cdef class PureRule(PureExpr):
    """
    A class which generates a Pure rule from `LHS` and `RHS` symbols.
    """
    cdef char* _stmt
    cdef public _pstmt

    def __cinit__(self, lhs, rhs):
        if isinstance(lhs,type("")):
            slhs = lhs
        else:
            slhs = cpure.str(g(lhs))

        if isinstance(rhs,type("")):
            srhs = rhs
        else:
            srhs = cpure.str(g(rhs))

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
    """
    A Pure integer primitive.
    """
    _type = 'int'
    number = None

    def __cinit__(self,i):
        if abs(i) > 2147483648:
            raise TypeError('Integer is larger than 32-bits.')
            return

        self._expr = cpure.pure_int(i)
        self._tag = self._expr.tag

cdef class PureDouble(PureExpr):
    """
    A Pure double primitive.
    """
    _type = 'double'
    number = None

    def __cinit__(self,i):
        self._expr = cpure.pure_double(i)
        self._tag = self._expr.tag

cdef class PureList(PureExpr):
    """
    A Pure list primitive.
    """
    _type = 'list'

    def __cinit__(self,*args):
        cdef pure_expr *xp
        cdef pure_expr *xps[10]
        for i in range(0,len(args)):
            xp = g(args[i])
            xps[i] = xp
        self._expr = cpure.pure_listv(len(args),xps)

#    def __getitem__(a,b):
#        return operator.__getitem__(a,PureInt(b))
#
#    def __getslice__(a,b,c):
#        return operator.__getslice__(a,PureInt(b),PureInt(c))

cdef class PureTuple(PureExpr):
    """
    A Pure tuple primitive.
    """
    _type = 'tuple'

    def __cinit__(self,*args):
        cdef pure_expr *xp
        cdef pure_expr *xps[10]
        for i in range(0,len(args)):
            xp = g(args[i])
            xps[i] = xp
        self._expr = cpure.pure_tuplev(len(args),xps)

cdef class PureLevel(PureExpr):
    """
    A Pure level instance.
    """
    _type = 'level'
    cdef uint32_t _hash

    def __cinit__(self,rules):
        # I can't figure out how to use the locals command in the
        # public API so we'll just use the eval until I can
        # figure out a better way

        rls = '; '.join(rules)
        cmd = ' '.join(['__locals__ with', rls, 'end;'])
        self._expr = cpure.pure_eval(cmd)
        self._hash = cpure.hash(self._expr)

    def hash(self):
        return self._hash

cdef pure_expr *g(PureExpr obj):
    """
    Cython function extract private _expr attribute and return it
    in a Cython context.
    """
    return obj._expr

def reduce_with_pure_rules(PureExpr level, PureExpr expr):
    '''Convert a Python list of strings into a dynamic local
    environment and pass reduce the given expression with it'''

    # Basically equivelent to
    # reduce_with expr __locals__ with rule1; rule2; end;

    cdef pure_expr *rexp
    rexp = cpure.reduce(level._expr, expr._expr)
    return PureExpr().se(rexp)

def new_level():
    """
    Spawn a new level in the interpreter.
    """
    cpure.pure_save()

def restore_level():
    """
    Restore previous level in the interpreter.
    """
    cpure.pure_restore()
