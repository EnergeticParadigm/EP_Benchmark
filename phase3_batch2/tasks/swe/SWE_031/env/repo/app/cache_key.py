def make_cache_key(user_id, region):
    return f"{user_id}:{region}"

def build_payload(user_id, region):
    return {"cache_key": make_cache_key(user_id, region)}
