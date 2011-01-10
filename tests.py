import unittest

from cpure import PureEnv, PureSymbol, PureInt, PureDouble
env = PureEnv()

class TestPureCythonModule(unittest.TestCase):

    def setUp(self):
        pass

    def test_interp(self):
        self.failIfEqual(env, None)
        self.failIfEqual(env.eval('1'),None)

    def test_primitives(self):
        self.assertEqual(str(env.eval('1+1')),'2')
        self.assertEqual(str(PureSymbol('x')),'x')
        self.assertEqual(str(PureInt(1)),'1')
        self.assertEqual(str(PureDouble(3.14)),'3.14')

    def test_prelude(self):
        env.eval('using prelude')
        self.assertEqual(str(env.eval('i2p $ x + y')),'add x y')
        self.assertEqual(str(env.eval('p2i $ add x y')),'x+y')

if __name__ == '__main__':
    unittest.main()

#vim: ai ts=4 sts=4 et sw=4
