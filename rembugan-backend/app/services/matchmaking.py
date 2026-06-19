def calculate_match_score(
    user_skills: list,
    required_skills: list,
    user_interest: str = "",
    project_interest: str = "",
) -> int:
    if not required_skills and not project_interest:
        return 100
    if not user_skills and not user_interest and not required_skills:
        return 100
    if not user_skills and not user_interest:
        return 0

    interest_match = 100 if (
        user_interest and project_interest
        and user_interest.lower().strip() == project_interest.lower().strip()
    ) else 0

    if not required_skills:
        skill_match = 100
    elif not user_skills:
        skill_match = 0
    else:
        user_set = {s.lower().strip() for s in user_skills}
        req_set = {s.lower().strip() for s in required_skills}
        matched = user_set.intersection(req_set)
        skill_match = int((len(matched) / len(req_set)) * 100)

    if not user_interest or not project_interest:
        return skill_match

    return int((interest_match * 0.5) + (skill_match * 0.5))
