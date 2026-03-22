import unittest
from app.cache_key import build_payload

class TestCacheKey(unittest.TestCase):
    def test_us(self):
        self.assertEqual(build_payload("u17", "us")["cache_key"], "u17:us")
    def test_eu(self):
        self.assertEqual(build_payload("u17", "eu")["cache_key"], "u17:eu")
    def test_distinct(self):
        self.assertNotEqual(build_payload("u17", "us")["cache_key"], build_payload("u17", "eu")["cache_key"])

if __name__ == "__main__":
    unittest.main()
