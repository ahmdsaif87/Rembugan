import asyncio
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import async_session_factory
from app.core.logger import get_logger
from app.models.user import User
from app.models.collaboration import Project

logger = get_logger(__name__)

_model = None
_model_lock = asyncio.Lock()


async def _get_model():
    global _model
    if _model is None:
        async with _model_lock:
            if _model is None:
                from fastembed import TextEmbedding
                loop = asyncio.get_running_loop()
                _model = await loop.run_in_executor(
                    None, lambda: TextEmbedding("BAAI/bge-small-en-v1.5")
                )
    return _model


async def generate(text: str) -> list[float]:
    if not text.strip():
        text = " "
    try:
        model = await _get_model()
        loop = asyncio.get_running_loop()
        emb = await loop.run_in_executor(None, lambda: list(model.embed(text))[0])
        return [float(v) for v in emb]
    except Exception as e:
        logger.warning(f"fastembed error: {e}")
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


async def reembed_user(session: AsyncSession, user_id: str):
    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user:
        txt = text_for_user(user)
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await session.execute(
                text(f'UPDATE "User" SET embedding = \'{vec}\'::vector WHERE id = :uid'),
                {"uid": user_id},
            )
            await session.commit()


async def reembed_project(session: AsyncSession, project_id: int):
    result = await session.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if project:
        txt = text_for_project(project.title, project.description, project.required_skills or [])
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await session.execute(
                text(f'UPDATE "Project" SET embedding = \'{vec}\'::vector WHERE id = :pid'),
                {"pid": project_id},
            )
            await session.commit()


async def reembed_showcase(session: AsyncSession, showcase_id: str):
    from app.models.social import Showcase
    result = await session.execute(select(Showcase).where(Showcase.id == showcase_id))
    showcase = result.scalar_one_or_none()
    if showcase:
        txt = text_for_showcase(showcase.content, showcase.tags or [])
        emb = await generate(txt)
        if emb:
            vec = f'[{",".join(str(x) for x in emb)}]'
            await session.execute(
                text(f'UPDATE "Showcase" SET embedding = \'{vec}\'::vector WHERE id = :sid'),
                {"sid": showcase_id},
            )
            await session.commit()
