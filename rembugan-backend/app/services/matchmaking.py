def calculate_match_score(
    user_skills: list,
    required_skills: list,
    user_interest: str = "",
    project_interest: str = "",
) -> int:
    if not required_skills and not project_interest:
        return 100
    if not user_skills and not user_interest:
        return 0

    user_set = {s.lower().strip() for s in user_skills}
    req_set = {s.lower().strip() for s in required_skills}
    matched = user_set.intersection(req_set)

    return int((len(matched) / len(req_set)) * 100)