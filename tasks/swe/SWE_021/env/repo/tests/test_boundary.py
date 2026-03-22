import unittest
from app.boundary import first_items

class TestBoundary(unittest.TestCase):
    def test_three(self):
        self.assertEqual(first_items([1,2,3,4], 3), [1,2,3])
    def test_zero(self):
        self.assertEqual(first_items([8,9], 0), [])
    def test_one(self):
        self.assertEqual(first_items([5,6,7], 1), [5])

if __name__ == "__main__":
    unittest.main()
