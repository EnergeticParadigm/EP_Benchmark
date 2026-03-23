def build_result(values):
    if not values:
        return {"count": 0, "items": []}
    return {"count": len(values), "items": values}
