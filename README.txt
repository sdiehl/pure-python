---------------------
Pure Python Interface
---------------------

Pure-python is a Cython wrapper for the Pure language
interpreter. It forms the backend for the rewrite capabilities
for Wise ( http://github.com/sdiehl/wise ).

Dependencies
---------------------

* Pure
* Python 2.6+
* Cython
* LLVM
* make
* gcc / clang

Build
--------------------

Run 'make all check'

Usage
---------------------

> from cpure import *
> A = PureSymbol("a")
> B = PureSymbol("b")
> D = PureInt(4)
> E = PureDouble(3.14159)
> F = PureSymbol("f")
> G = PureList(A,B)

> print A+B, A*B, A/B
a+b, a*b, a/b

> print D+D, D/D, D+A, D+E
8, 1, 4+a, 7.14159

> print F(A), F(D), F(A,B), F(F(A+B))
f a, f 4, f a b, f (f a+b)

> print G, F(G)
[a, b] , f [a,b]

AUTHORS
--------------------

Written by Stephen Diehl ( sdiehl@clarku.edu )

CREDITS
--------------------

Pure
http://code.google.com/p/pure-lang
Copyright Albert Graef

License
--------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses> .
