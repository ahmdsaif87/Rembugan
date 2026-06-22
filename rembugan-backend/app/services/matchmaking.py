<<<<<<< Updated upstream
def calculate_match_score(user_skills: list, required_skills: list) -> int:
    """
    Menghitung persentase kecocokan skill user dengan kebutuhan proyek.
    Menggunakan set intersection — O(N) time complexity.
    
    Returns:
        int: Persentase kecocokan (0-100)
    """
    if not required_skills:
        return 100  # Proyek tanpa skill khusus = 100% cocok
    if not user_skills:
=======
def calculate_match_score(
    user_skills: list,
    required_skills: list,
    user_interest: str = "",
    project_interest: str = "",
) -> int:
    if not required_skills and not project_interest:
        return 0
    if not user_skills and not user_interest:
>>>>>>> Stashed changes
        return 0

    user_set = {s.lower().strip() for s in user_skills}
    req_set = {s.lower().strip() for s in required_skills}
    matched = user_set.intersection(req_set)

    return int((len(matched) / len(req_set)) * 100)