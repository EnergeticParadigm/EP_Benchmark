import unittest
from app.range_sum import sum_first_n

class TestRangeSum(unittest.TestCase):
    def test_first_three(self):
        self.assertEqual(sum_first_n([1, 2, 3, 4], 3), 6)

    def test_first_one(self):
        self.assertEqual(sum_first_n([7, 9, 11], 1), 7)

    def test_zero(self):
        self.assertEqual(sum_first_n([5, 6, 7], 0), 0)

if __name__ == "__main__":
    unittest.main()
