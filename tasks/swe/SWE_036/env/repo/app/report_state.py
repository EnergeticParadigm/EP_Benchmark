def build_state(ok, code):
    if ok:
        return {"status": "ok", "code": code}
    return {"status": "fail", "code": code}
