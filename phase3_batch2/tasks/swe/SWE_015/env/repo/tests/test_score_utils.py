import unittest
from app.score_utils import normalize_score

class TestScoreUtils(unittest.TestCase):
    def test_mid_value(self):
        self.assertEqual(normalize_score(55), 55)

    def test_high_value(self):
        self.assertEqual(normalize_score(140), 100)

    def test_negative_value(self):
        self.assertEqual(normalize_score(-7), 0)

if __name__ == "__main__":
    unittest.main()
