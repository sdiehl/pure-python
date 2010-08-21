from pure import *

A = PureSymbol("a")
B = PureSymbol("b")
C = PureSymbol("c")
D = PureInt(4)
E = PureDouble(3.14159)
F = PureSymbol("f")
PureRule(F(A,B,C),B*B-D*A*C)
G = PureList(A,B,C)

print F.refc
print A.refc
print B.refc
C = PureRule(F(A),B)
Q = PureRule(F(A,B),PureList(A,B))

print reduce_with(Q,F(A,B))
assert A == PureSymbol("a")
assert B == env.eval("b")
assert C.type == 'symbol'
assert A.tag == 346
assert A.tag != B.tag
assert F(D,D,D) == PureInt(48)
assert G[0] == A
assert G[0:1] == PureList(A,B)
