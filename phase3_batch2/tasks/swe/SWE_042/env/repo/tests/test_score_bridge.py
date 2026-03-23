import unittest
from app.score_bridge import final_percentage

class TestScoreBridge(unittest.TestCase):
    def test_mid(self):
        self.assertEqual(final_percentage(55), 55)
    def test_high(self):
        self.assertEqual(final_percentage(140), 100)
    def test_low(self):
        self.assertEqual(final_percentage(-3), 0)

if __name__ == "__main__":
    unittest.main()
