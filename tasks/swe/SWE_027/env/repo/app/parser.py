import re

def extract_order_id(text):
    m = re.search(r"order-\d+(?![A-Za-z0-9_])", text)
    return None if m is None else m.group(0)
