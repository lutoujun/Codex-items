import sys
import unittest
from pathlib import Path

SRC_DIR = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SRC_DIR))

from ads_bi_supply_chain_stock_analyse_info_roll import roll


class RollTest(unittest.TestCase):
    def test_inventory_labels_use_estimated_sales_when_sales_fields_differ(self):
        row = (
            "pkey", "2026-07-29", "PMC", "MSKU-001", "L1", "Level 1", "C2", "Category 2",
            "202630-1", 202630, "2026-07-23", "2026-07-29", "Y", 700, 0, 0, 70, 700,
        )

        result = roll([row])[0]

        self.assertEqual(630, result[19])
        self.assertEqual(70, result[20])
        self.assertEqual("[60-90]", result[21])
        self.assertEqual("风险库存", result[22])
        self.assertEqual((300, 300, 100, 0), result[23:27])


if __name__ == "__main__":
    unittest.main()
