from pure import PureSymbol

# There is an almost 1:1 correspondence between Python operators and
# Pure operators

__add__ = PureSymbol('+')
__sub__ = PureSymbol('-')
__div__ = PureSymbol('/')
__or__ = PureSymbol('or')
__mul__ = PureSymbol('*')
__neg__ = PureSymbol('neg')
__getitem__ =  PureSymbol('!')
__getslice__ = PureSymbol('!!')

def add(a,b):
    return __add__(a,b)

def sub(a,b):
    return __sub__(a,b)

def div(a,b):
    return __div__(a,b)

def neg(a):
    return __neg__(a)

def mul(a,b):
    return __mul__(a,b)

def getitem(a,b):
    return __getitem__(a,b)

def getslice(a,b,c):
    return __getslice__(a,b,c)


#pure.PureSymbol('$$')
#pure.PureSymbol('$')
#pure.PureSymbol(',')
#pure.PureSymbol('=>')
#pure.PureSymbol('..')
#pure.PureSymbol('||')
#pure.PureSymbol('&&')
#pure.PureSymbol('~')
#pure.PureSymbol('< > <= >= == ~=')
#pure.PureSymbol('=== ~==')
#pure.PureSymbol(':')
#pure.PureSymbol('+: <:')
#pure.PureSymbol('<< >>')
#pure.PureSymbol('* / div mod and')
#pure.PureSymbol('%')
#pure.PureSymbol('not')
#pure.PureSymbol('^')
#pure.PureSymbol('#')
#pure.PureSymbol('.')
#pure.PureSymbol("'")
#pure.PureSymbol('&')
