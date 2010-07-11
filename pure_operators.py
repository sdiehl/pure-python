from pure import PureSymbol

#operator.dog = pure.PureSymbol('$$')
#operator.dog = pure.PureSymbol('$')
#operator.dog = pure.PureSymbol(',')
#operator.dog = pure.PureSymbol('=>')
#operator.dog = pure.PureSymbol('..')
#operator.dog = pure.PureSymbol('||')
#operator.dog = pure.PureSymbol('&&')
#operator.dog = pure.PureSymbol('~')
#operator.dog = #pure.PureSymbol('< > <= >= == ~=')
#operator.dog = #pure.PureSymbol('=== ~==')
#operator.dog = pure.PureSymbol(':')
#operator.dog = #pure.PureSymbol('+: <:')
#operator.dog = #pure.PureSymbol('<< >>')
__add__ = PureSymbol('+')
__sub__ = PureSymbol('-')
__div__ = PureSymbol('/')
__or__ = PureSymbol('or')
__mul__ = PureSymbol('*')
#operator.dog = #pure.PureSymbol('* / div mod and')
#operator.dog = pure.PureSymbol('%')
#operator.dog = pure.PureSymbol('not')
#operator.dog = pure.PureSymbol('^')
#operator.dog = pure.PureSymbol('#')
#operator.dog = #pure.PureSymbol('! !!')
#operator.dog = pure.PureSymbol('.')
#operator.dog = pure.PureSymbol("'")
#operator.dog = pure.PureSymbol('&')

def add(a,b):
    return __add__(a,b)

def sub(a,b):
    return __sub__(a,b)

def mul(a,b):
    return __mul__(a,b)

def div(a,b):
    return __div__(a,b)
