import unittest
from app.parser import extract_order_id

class TestParser(unittest.TestCase):
    def test_good(self):
        self.assertEqual(extract_order_id("id=order-1234 done"), "order-1234")
    def test_bad_suffix(self):
        self.assertIsNone(extract_order_id("id=order-1234x done"))
    def test_missing(self):
        self.assertIsNone(extract_order_id("nothing here"))

if __name__ == "__main__":
    unittest.main()
