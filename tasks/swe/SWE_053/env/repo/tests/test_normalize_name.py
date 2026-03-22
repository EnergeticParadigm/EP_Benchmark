import unittest
from app.normalize_name import normalize_name

class TestNormalizeName(unittest.TestCase):
    def test_spaces(self):
        self.assertEqual(normalize_name("  Alice Bob  "), "alice_bob")
    def test_case(self):
        self.assertEqual(normalize_name("CAROL"), "carol")
    def test_inner_space(self):
        self.assertEqual(normalize_name("Dan Eve"), "dan_eve")

if __name__ == "__main__":
    unittest.main()
