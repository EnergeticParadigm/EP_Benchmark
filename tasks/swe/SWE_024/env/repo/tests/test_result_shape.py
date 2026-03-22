import unittest
from app.result_shape import build_result

class TestResultShape(unittest.TestCase):
    def test_empty(self):
        self.assertEqual(build_result([]), {"count": 0, "items": []})
    def test_non_empty(self):
        self.assertEqual(build_result([1,2]), {"count": 2, "items": [1,2]})
    def test_keys(self):
        self.assertEqual(set(build_result([]).keys()), {"count", "items"})

if __name__ == "__main__":
    unittest.main()
