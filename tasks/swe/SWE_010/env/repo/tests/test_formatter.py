import unittest
from app.formatter import normalize_result

class TestFormatter(unittest.TestCase):
    def test_true_branch(self):
        self.assertEqual(normalize_result(True, 7), {"result": 7})

    def test_false_branch_type(self):
        result = normalize_result(False, 9)
        self.assertIsInstance(result, dict)
        self.assertEqual(result, {"result": 9})

    def test_consistent_shape(self):
        a = normalize_result(True, 3)
        b = normalize_result(False, 3)
        self.assertEqual(set(a.keys()), set(b.keys()))

if __name__ == "__main__":
    unittest.main()
