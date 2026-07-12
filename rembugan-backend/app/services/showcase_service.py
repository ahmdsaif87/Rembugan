from fastapi import Depends, HTTPException
from sqlalchemy import select, or_, and_, text, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import NOTIF_LIKE, NOTIF_COMMENT, NOTIF_CHAT
from app.core.types import ShowcaseData
from app.models import User, Showcase, ShowcaseLike, ShowcaseComment, Connection
from app.services.notification import notify
from app.core.cache import cache
from app.core.tasks import fire_and_forget
from app.services.embedding import reembed_showcase


class ShowcaseService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def create(self, user_id: str, content: str, media_urls: list[str], tags: list[str], linked_project_id: int | None):
        showcase = Showcase(
            author_id=user_id,
            content=content,
            media_urls=media_urls,
            tags=tags,
            linked_project_id=linked_project_id,
        )
        self.session.add(showcase)
        await self.session.commit()
        await self.session.refresh(showcase)
        fire_and_forget(reembed_showcase(showcase.id), name="reembed_showcase")
        return showcase

    async def get_feed(self, user_id: str, page: int, limit: int) -> tuple[list[ShowcaseData], int]:
        cache_key = f"feed:{user_id}:{page}:{limit}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached["data"], cached["total"]

        result = await self.session.execute(
            text('SELECT embedding::text FROM "User" WHERE id = :uid'),
            {"uid": user_id},
        )
        row = result.fetchone()
        user_emb = None
        if row and row[0]:
            import json
            user_emb = json.loads(row[0])

        result = await self.session.execute(
            select(func.count(Showcase.id)).where(Showcase.author_id != user_id)
        )
        total = result.scalar() or 0

        if user_emb:
            vec_str = f'[{",".join(str(x) for x in user_emb)}]'
            rows_result = await self.session.execute(
                text(
                    f'SELECT id, 1 - (embedding <=> \'{vec_str}\'::vector) AS match_score '
                    f'FROM "Showcase" WHERE author_id != :uid '
                    f'AND 1 - (embedding <=> \'{vec_str}\'::vector) > 0.15 '
                    f'ORDER BY embedding <=> \'{vec_str}\'::vector '
                    'OFFSET :offset LIMIT :lim'
                ),
                {"uid": user_id, "offset": (page - 1) * limit, "lim": limit},
            )
            rows = rows_result.fetchall()
            ids = [r[0] for r in rows]
            score_map = {r[0]: float(r[1]) for r in rows}
        else:
            ids = []
            score_map = {}

        if not ids:
            result = await self.session.execute(
                select(Showcase)
                .where(Showcase.author_id != user_id)
                .order_by(Showcase.created_at.desc())
                .offset((page - 1) * limit)
                .limit(limit)
            )
            showcases = result.scalars().all()
        else:
            result = await self.session.execute(
                select(Showcase).where(Showcase.id.in_(ids))
            )
            showcases = result.scalars().all()

        author_ids = list(set(s.author_id for s in showcases))
        conn_map = {}
        if author_ids:
            result = await self.session.execute(
                select(Connection).where(
                    or_(
                        and_(Connection.sender_id == user_id, Connection.receiver_id.in_(author_ids)),
                        and_(Connection.sender_id.in_(author_ids), Connection.receiver_id == user_id),
                    )
                )
            )
            conns = result.scalars().all()
            for conn in conns:
                other_id = conn.receiver_id if conn.sender_id == user_id else conn.sender_id
                conn_map[other_id] = conn.status

        data = []
        for s in showcases:
            data.append({
                "id": s.id,
                "author_id": s.author_id,
                "author_name": None,
                "author_photo": None,
                "author_major": None,
                "author_faculty": None,
                "connection_status": conn_map.get(s.author_id),
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "likes_count": len(s.likes) if s.likes else 0,
                "comments_count": len(s.comments) if s.comments else 0,
                "liked_by_me": any(l.user_id == user_id for l in (s.likes or [])),
                "match_score": int(score_map.get(s.id, 0) * 100),
                "created_at": s.created_at.isoformat(),
            })

        # Batch fetch authors
        if author_ids:
            result = await self.session.execute(select(User).where(User.id.in_(author_ids)))
            users = {u.id: u for u in result.scalars().all()}
            for d in data:
                u = users.get(d["author_id"])
                if u:
                    d["author_name"] = u.full_name
                    d["author_photo"] = u.photo_url
                    d["author_major"] = u.major
                    d["author_faculty"] = u.faculty

        await cache.set(cache_key, {"data": data, "total": total}, ttl=60)
        return data, total

    async def get_following_feed(self, user_id: str, page: int, limit: int) -> tuple[list[ShowcaseData], int]:
        result = await self.session.execute(
            select(Connection).where(
                or_(
                    and_(Connection.sender_id == user_id, Connection.status == "accepted"),
                    and_(Connection.receiver_id == user_id, Connection.status == "accepted"),
                )
            )
        )
        connected = result.scalars().all()
        connected_ids = set()
        for c in connected:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        if not connected_ids:
            return [], 0

        result = await self.session.execute(
            select(func.count(Showcase.id)).where(Showcase.author_id.in_(list(connected_ids)))
        )
        total = result.scalar() or 0

        offset = (page - 1) * limit
        result = await self.session.execute(
            select(Showcase)
            .where(Showcase.author_id.in_(list(connected_ids)))
            .order_by(Showcase.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        showcases = result.scalars().all()

        author_ids = list(set(s.author_id for s in showcases))
        users_map = {}
        if author_ids:
            result = await self.session.execute(select(User).where(User.id.in_(author_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        data = []
        for s in showcases:
            u = users_map.get(s.author_id)
            data.append({
                "id": s.id,
                "author_id": s.author_id,
                "author_name": u.full_name if u else None,
                "author_photo": u.photo_url if u else None,
                "author_major": u.major if u else None,
                "author_faculty": u.faculty if u else None,
                "connection_status": "accepted",
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "likes_count": len(s.likes) if s.likes else 0,
                "comments_count": len(s.comments) if s.comments else 0,
                "liked_by_me": any(l.user_id == user_id for l in (s.likes or [])),
                "match_score": 0,
                "created_at": s.created_at.isoformat(),
            })

        return data, total

    async def get_mine(self, user_id: str) -> list[ShowcaseData]:
        result = await self.session.execute(
            select(Showcase)
            .where(Showcase.author_id == user_id)
            .order_by(Showcase.created_at.desc())
        )
        showcases = result.scalars().all()
        return [{
            "id": s.id,
            "content": s.content,
            "media_urls": s.media_urls,
            "tags": s.tags,
            "likes_count": len(s.likes) if s.likes else 0,
            "comments_count": len(s.comments) if s.comments else 0,
            "created_at": s.created_at.isoformat(),
        } for s in showcases]

    async def get_detail(self, showcase_id: str, user_id: str) -> ShowcaseData:
        result = await self.session.execute(
            select(Showcase).where(Showcase.id == showcase_id)
        )
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        # Fetch likes with users
        result = await self.session.execute(
            select(ShowcaseLike).where(ShowcaseLike.showcase_id == showcase_id)
        )
        likes = result.scalars().all()
        liked = any(l.user_id == user_id for l in likes)

        # Fetch comments
        result = await self.session.execute(
            select(ShowcaseComment)
            .where(ShowcaseComment.showcase_id == showcase_id)
            .order_by(ShowcaseComment.created_at)
        )
        all_comments = result.scalars().all()

        top_level = [c for c in all_comments if c.parent_id is None]
        comments_map = {c.id: c for c in all_comments}

        # Batch fetch comment users
        comment_user_ids = {c.user_id for c in all_comments}
        users_map = {}
        if comment_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(comment_user_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        comments_data = []
        for c in top_level:
            replies = sorted(
                [r for r in all_comments if r.parent_id == c.id],
                key=lambda r: r.created_at,
            )
            replies_data = []
            for i, r in enumerate(replies):
                reply_to_name = users_map.get(c.user_id).full_name if users_map.get(c.user_id) else None
                if i > 0:
                    prev = replies[i - 1]
                    if prev.user_id != r.user_id:
                        prev_user = users_map.get(prev.user_id)
                        reply_to_name = prev_user.full_name if prev_user else None
                replies_data.append({
                    "id": r.id,
                    "user_id": r.user_id,
                    "full_name": users_map.get(r.user_id).full_name if users_map.get(r.user_id) else None,
                    "photo_url": users_map.get(r.user_id).photo_url if users_map.get(r.user_id) else None,
                    "content": r.content,
                    "created_at": r.created_at.isoformat(),
                    "reply_to_name": reply_to_name,
                })

            comments_data.append({
                "id": c.id,
                "user_id": c.user_id,
                "full_name": users_map.get(c.user_id).full_name if users_map.get(c.user_id) else None,
                "photo_url": users_map.get(c.user_id).photo_url if users_map.get(c.user_id) else None,
                "content": c.content,
                "replies": replies_data,
                "created_at": c.created_at.isoformat(),
            })

        # Fetch author
        result = await self.session.execute(select(User).where(User.id == showcase.author_id))
        author = result.scalar_one_or_none()

        return {
            "id": showcase.id,
            "author_id": showcase.author_id,
            "author_name": author.full_name if author else None,
            "author_photo": author.photo_url if author else None,
            "content": showcase.content,
            "media_urls": showcase.media_urls,
            "tags": showcase.tags,
            "likes_count": len(likes),
            "liked_by_me": liked,
            "comments": comments_data,
            "created_at": showcase.created_at.isoformat(),
        }

    async def like(self, showcase_id: str, user_id: str):
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        existing = await self.session.execute(
            select(ShowcaseLike).where(
                ShowcaseLike.showcase_id == showcase_id,
                ShowcaseLike.user_id == user_id,
            )
        )
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=400, detail="Anda sudah menyukai showcase ini")

        like = ShowcaseLike(showcase_id=showcase_id, user_id=user_id)
        self.session.add(like)
        await self.session.commit()

        if showcase.author_id != user_id:
            result = await self.session.execute(select(User).where(User.id == user_id))
            liker = result.scalar_one_or_none()
            await notify(
                self.session, showcase.author_id, NOTIF_LIKE,
                "Seseorang menyukai postingan Anda",
                f"{liker.full_name if liker else 'Seseorang'} menyukai postingan '{showcase.content[:20]}...'",
                f"/showcase/{showcase_id}",
            )

    async def unlike(self, showcase_id: str, user_id: str):
        result = await self.session.execute(
            select(ShowcaseLike).where(
                ShowcaseLike.showcase_id == showcase_id,
                ShowcaseLike.user_id == user_id,
            )
        )
        like = result.scalar_one_or_none()
        if not like:
            raise HTTPException(status_code=404, detail="Anda belum menyukai showcase ini")
        await self.session.delete(like)
        await self.session.commit()

    async def comment(self, showcase_id: str, user_id: str, content: str, parent_id: int | None):
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        comment = ShowcaseComment(
            showcase_id=showcase_id,
            user_id=user_id,
            content=content,
            parent_id=parent_id,
        )
        self.session.add(comment)
        await self.session.commit()
        await self.session.refresh(comment)

        result = await self.session.execute(select(User).where(User.id == user_id))
        commenter = result.scalar_one_or_none()

        if showcase.author_id != user_id:
            await notify(
                self.session, showcase.author_id, NOTIF_COMMENT,
                "Seseorang mengomentari postingan Anda",
                f"{commenter.full_name if commenter else 'Seseorang'} mengomentari: '{content[:30]}'",
                f"/showcase/{showcase_id}",
            )

        if parent_id:
            result = await self.session.execute(
                select(ShowcaseComment).where(ShowcaseComment.id == parent_id)
            )
            parent = result.scalar_one_or_none()
            if parent and parent.user_id != user_id:
                await notify(
                    self.session, parent.user_id, NOTIF_COMMENT,
                    "Seseorang membalas komentar Anda",
                    f"{commenter.full_name if commenter else 'Seseorang'} membalas komentar Anda.",
                    f"/showcase/{showcase_id}",
                )

        return comment

    async def get_share_link(self, showcase_id: str) -> str:
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        import os
        app_url = os.getenv("APP_URL", "https://rembugan.app")
        return f"{app_url}/s/{showcase_id}"

    async def share_to_user(self, showcase_id: str, sender_id: str, receiver_id: str):
        import os
        from app.models.chat import Message
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        result = await self.session.execute(select(User).where(User.id == receiver_id))
        receiver = result.scalar_one_or_none()
        if not receiver:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        app_url = os.getenv("APP_URL", "https://rembugan.app")
        link = f"{app_url}/s/{showcase_id}"
        result = await self.session.execute(select(User).where(User.id == sender_id))
        sender = result.scalar_one_or_none()
        content = f"{sender.full_name if sender else 'Seseorang'} membagikan postingan: {link}"

        msg = Message(content=content, sender_id=sender_id, receiver_id=receiver_id)
        self.session.add(msg)
        await self.session.commit()

        await notify(
            self.session, receiver_id, NOTIF_CHAT,
            "Postingan dibagikan ke Anda",
            content[:60],
            f"/chat/dm_{sender_id}_{receiver_id}",
        )

        return link
