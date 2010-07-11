cimport pure
cimport python_exc

env = PureEnv()

import pure_operators as operator

cdef class PureEnv:
    cdef pure_interp *_interp

    def __cinit__(self):
        print "Creating interpreter instance."
        self._interp = pure.pure_create_interp(0,NULL)
        if self._interp is NULL:
            python_exc.PyErr_NoMemory()

    def __dealloc__(self):
        pass

    cpdef eval(self, s):
        cdef pure_expr *y
        y = pure.pure_eval(s)
        if y == NULL:
            print "Could not parse"
        else:
            return (PureExpr().se(y))

cdef class PureExpr:
    cdef pure_expr *_expr
    cpdef int _tag
    cpdef int _refc
    _type = None

    def __cinit__(self):
        pass

    cdef se(self, pure_expr *ex):
        self._expr = ex
        self._tag = ex.tag
        return self

    @property
    def tag(self):
        self._tag = self._expr.tag
        return self._tag

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

    def __richcmp__(self, PureExpr other, int op):
        if op == 2:
            return (self.tag) == (other.tag)
        else:
            return False

    def __add__(self,other):
        return operator.add(self,other)

    def __sub__(self,other):
        return operator.sub(self,other)

    def __mul__(self,other):
        return operator.mul(self,other)

    def __div__(self,other):
        return operator.div(self,other)

cdef class PureApp(PureExpr):
    _type = 'app'
    cdef PureExpr _head
    cdef char* _sym

    def __invert__(self):
        return PureQuotedSymbol(self._sym)

    def set_head(self, head):
        self._head = head

    def get_head(self):
        return self._head

cdef class PureSymbol(PureExpr):
    _type = 'symbol'
    cdef char* _sym

    def __cinit__(self,sym):
       self._sym = sym
       self._expr = pure.pure_symbol(pure.pure_sym(sym))
       self._tag = self._expr.tag

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

cdef class PureRule(PureExpr):
    cdef char* stmt

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
        print "Setting",stmt
        self.stmt = stmt
        pure.pure_eval(stmt)

        if isinstance(lhs,PureApp):
            print 'Changing head'
            lhs.get_head().update()

    def __repr__(self):
        return self.stmt

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

cdef class PureTuple(PureExpr):
    _type = 'tuple'

    def __cinit__(self,*args):
        cdef pure_expr *xp
        cdef pure_expr *xps[10]
        for i in range(0,len(args)):
            xp = g(args[i])
            xps[i] = xp
        self._expr = pure.pure_tuplev(len(args),xps)

cdef pure_expr *g(PureExpr obj):
    return obj._expr
