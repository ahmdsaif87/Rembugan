from fastembed import TextEmbedding

_model: TextEmbedding | None = None


def _get_model() -> TextEmbedding:
    global _model
    if _model is None:
        _model = TextEmbedding("BAAI/bge-small-en-v1.5")
    return _model


def generate(text: str) -> list[float]:
    if not text.strip():
        text = " "
    emb = list(_get_model().embed(text))[0]
    return [float(v) for v in emb]


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
    from prisma import Json
    user = await db.user.find_unique(
        where={"id": user_id},
        include={"skills": {"include": {"skill": True}}},
    )
    if user:
        txt = text_for_user(user)
        emb = generate(txt)
        await db.user.update(where={"id": user_id}, data={"embedding": Json(emb)})


async def reembed_project(db, project_id: int):
    from prisma import Json
    project = await db.project.find_unique(where={"id": project_id})
    if project:
        txt = text_for_project(project.title, project.description, project.required_skills or [], project.interest)
        emb = generate(txt)
        await db.project.update(where={"id": project_id}, data={"embedding": Json(emb)})


async def reembed_showcase(db, showcase_id: str):
    from prisma import Json
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if showcase:
        txt = text_for_showcase(showcase.content, showcase.tags or [])
        emb = generate(txt)
        await db.showcase.update(where={"id": showcase_id}, data={"embedding": Json(emb)})
