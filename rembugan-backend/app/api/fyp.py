import httpx
from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo

from app.core.security import verify_token
from app.core.database import get_db
from app.services.matchmaking import calculate_match_score
from app.api.competitions import collection as competition_collection

router = APIRouter(prefix="/fyp", tags=["Halaman Beranda (FYP)"])

@router.get("/", summary="Ambil Data Personalized FYP")
async def get_fyp(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Endpoint untuk mengambil Personalized FYP:
    - Portofolio/Showcase (terbaru)
    - Tawaran Proyek (diurutkan berdasarkan relevansi skill)
    - Info Lomba (diurutkan berdasarkan relevansi skill)
    """
    uid = user_token.get("uid")

    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")

    user_skills = [s.skill.name for s in user.skills] if user.skills else []
    user_skills_lower = [s.lower() for s in user_skills]

    # 1. Ambil Showcase (Limit 10 terbaru)
    showcases = await db.showcase.find_many(
        take=10,
        order={"created_at": "desc"},
        include={"author": True, "project": True, "likes": True, "comments": True}
    )
    showcase_data = []
    for s in showcases:
        showcase_data.append({
            "id": s.id,
            "type": "showcase",
            "content": s.content,
            "media_urls": s.media_urls,
            "tags": s.tags,
            "author_name": s.author.full_name if s.author else None,
            "author_photo": s.author.photo_url if s.author else None,
            "likes_count": len(s.likes) if s.likes else 0,
            "comments_count": len(s.comments) if s.comments else 0,
            "created_at": s.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        })

    # 2. Ambil Project Offerings (Limit 10 paling relevan)
    projects = await db.project.find_many(
        where={"status": "open", "owner_id": {"not": uid}},
        include={"owner": True},
    )
    scored_projects = []
    for p in projects:
        score = calculate_match_score(user_skills, p.required_skills)
        scored_projects.append({
            "id": p.id,
            "type": "project",
            "title": p.title,
            "description": p.description,
            "required_skills": p.required_skills,
            "owner_name": p.owner.full_name if p.owner else None,
            "match_score": score,
            "created_at": p.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        })
    scored_projects.sort(key=lambda x: x["match_score"], reverse=True)
    project_data = scored_projects[:10]

    # 3. Ambil Lomba (Limit 5 paling relevan)
    competition_data = []
    try:
        cursor = competition_collection.find({}).limit(50)
        lomba_data = await cursor.to_list(length=50)
        for item in lomba_data:
            item["_id"] = str(item["_id"])
            score = 0
            text_to_search = f"{item.get('judul', '')} {item.get('caption', '')}".lower()
            for us in user_skills_lower:
                if us in text_to_search:
                    score += 1
            
            if score > 0 or len(user_skills) == 0:
                c_item = dict(item)
                c_item["type"] = "competition"
                c_item["match_score"] = score
                competition_data.append(c_item)
        
        competition_data.sort(key=lambda x: x.get('match_score', 0), reverse=True)
        competition_data = competition_data[:5]
    except Exception as e:
        # Jangan sampai gagalkan endpoint ini jika API Lomba mati
        print(f"Error fetching lomba: {e}")

    return {
        "status": "success",
        "data": {
            "showcases": showcase_data,
            "projects": project_data,
            "competitions": competition_data
        }
    }
