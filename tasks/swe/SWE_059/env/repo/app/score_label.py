def score_label(score):
    if score >= 80:
        return "gold"
    if score >= 50:
        return "silver"
    return "bronze"
