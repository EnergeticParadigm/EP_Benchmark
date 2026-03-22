import unittest
from app.report_state import build_state

class TestReportState(unittest.TestCase):
    def test_ok_branch(self):
        self.assertEqual(build_state(True, 7), {"status": "ok", "code": 7})
    def test_fail_branch_type(self):
        result = build_state(False, 7)
        self.assertIsInstance(result, dict)
    def test_fail_branch_value(self):
        self.assertEqual(build_state(False, 7), {"status": "fail", "code": 7})

if __name__ == "__main__":
    unittest.main()
