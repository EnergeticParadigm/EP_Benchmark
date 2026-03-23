import unittest
from app.first_record import first_record

class TestFirstRecord(unittest.TestCase):
    def test_empty(self):
        self.assertIsNone(first_record([]))
    def test_first(self):
        self.assertEqual(first_record([{"id": 1}, {"id": 2}]), {"id": 1})
    def test_no_mutation(self):
        data = [{"id": 3}]
        self.assertEqual(first_record(data), {"id": 3})

if __name__ == "__main__":
    unittest.main()
