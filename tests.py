from pure import PureEnv, PureSymbol

env = PureEnv()
print env.eval('using prelude')
print env.eval('i2p (x + y)')

#assert env != None
#assert env.eval('1') != None
#
#assert str(PureSymbol('x')) == 'x'
#
#print 'Passed all tests!'
