import asyncio
import os
import httpx
from app.core.logger import get_logger

logger = get_logger(__name__)

HF_TOKEN = os.getenv("HF_TOKEN", "")
HF_MODEL = "BAAI/bge-small-en-v1.5"
HF_API_URL = f"https://api-inference.huggingface.co/pipeline/feature-extraction/{HF_MODEL}"
_embedding_cache: dict[str, list[float]] = {}


async def generate(text: str) -> list[float]:
    if not text.strip():
        text = " "
    cached = _embedding_cache.get(text)
    if cached is not None:
        return cached
    if not HF_TOKEN:
        logger.warning("HF_TOKEN tidak diset — embedding tidak bisa digenerate")
        return []
    headers = {"Authorization": f"Bearer {HF_TOKEN}"}
    payload = {"inputs": text, "options": {"wait_for_model": True}}
    for attempt in range(2):
        try:
            async with httpx.AsyncClient(timeout=15) as client:
                resp = await client.post(HF_API_URL, json=payload, headers=headers)
                resp.raise_for_status()
                data = resp.json()
                emb = data[0] if isinstance(data, list) and isinstance(data[0], list) else data
                result = [float(v) for v in emb]
                if len(text) < 500:
                    _embedding_cache[text] = result
                return result
        except Exception as e:
            if attempt == 0:
                logger.warning(f"HuggingFace API error (retry): {e}")
                continue
            logger.warning(f"HuggingFace API error (fallback ke empty): {e}")
            return []


def cosine_similarity(a: list[float], b: list[float]) -> float:
    if not a or not b:
        return 0.0
    dot = sum(x * y for x, y in zip(a, b))
    na = sum(x * x for x in a) ** 0.5
    nb = sum(x * x for x in b) ** 0.5
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def text_for_user(user) -> str:
    parts = []
    if user.skills:
        parts.append(" ".join(s.skill.name for s in user.skills))
    if user.interest:
        parts.append(user.interest)
    return " ".join(parts)


def text_for_project(title: str, description: str, required_skills: list[str], interest: str | None = None) -> str:
    parts = [title, description]
    if required_skills:
        parts.append(" ".join(required_skills))
    if interest:
        parts.append(interest)
    return " ".join(parts)


def text_for_showcase(content: str, tags: list[str]) -> str:
    parts = [content]
    if tags:
        parts.append(" ".join(tags))
    return " ".join(parts)


async def reembed_user(db, user_id: str):
    user = await db.user.find_unique(
        where={"id": user_id},
        include={"skills": {"include": {"skill": True}}},
    )
    if user:
        txt = text_for_user(user)
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await db.query_raw(
                'UPDATE "User" SET embedding = $1::vector WHERE id = $2',
                vec, user_id
            )


async def reembed_project(db, project_id: int):
    project = await db.project.find_unique(where={"id": project_id})
    if project:
        txt = text_for_project(project.title, project.description, project.required_skills or [])
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await db.query_raw(
                'UPDATE "Project" SET embedding = $1::vector WHERE id = $2',
                vec, project_id
            )


async def reembed_showcase(db, showcase_id: str):
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if showcase:
        txt = text_for_showcase(showcase.content, showcase.tags or [])
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await db.query_raw(
                'UPDATE "Showcase" SET embedding = $1::vector WHERE id = $2',
                vec, showcase_id
            )
