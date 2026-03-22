import unittest
from app.score_label import score_label

class TestScoreLabel(unittest.TestCase):
    def test_gold(self):
        self.assertEqual(score_label(95), "gold")
    def test_silver(self):
        self.assertEqual(score_label(60), "silver")
    def test_bronze(self):
        self.assertEqual(score_label(20), "bronze")

if __name__ == "__main__":
    unittest.main()
