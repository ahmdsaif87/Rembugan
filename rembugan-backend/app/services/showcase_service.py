from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import NOTIF_LIKE, NOTIF_COMMENT, NOTIF_CHAT
from app.core.types import ShowcaseData
from app.services.notification import notify
from app.core.cache import cache
from app.services.embedding import cosine_similarity, reembed_showcase


class ShowcaseService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def create(self, user_id: str, content: str, media_urls: list[str], tags: list[str], linked_project_id: int | None):
        showcase = await self.db.showcase.create(data={
            "author_id": user_id,
            "content": content,
            "media_urls": media_urls,
            "tags": tags,
            "linked_project_id": linked_project_id,
        })
        await reembed_showcase(self.db, showcase.id)
        return showcase

    async def get_feed(self, user_id: str, page: int, limit: int) -> tuple[list[ShowcaseData], int]:
        user = await self.db.user.find_unique(where={"id": user_id})
        user_emb = user.embedding if user else None

        cache_key = f"feed:{user_id}:{page}:{limit}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached["data"], cached["total"]

        total = await self.db.showcase.count()
        showslimit = min(total, 100)
        offset = (page - 1) * limit
        showcases = await self.db.showcase.find_many(
            order={"created_at": "desc"},
            skip=offset,
            take=showslimit,
            include={"author": True, "likes": True, "comments": True},
        )

        scored = []
        for s in showcases:
            s_emb = s.embedding
            score = cosine_similarity(user_emb, s_emb) if user_emb and s_emb else 0.0
            scored.append((score, s))

        scored.sort(key=lambda x: x[0], reverse=True)

        start = (page - 1) * limit
        page_scored = scored[start:start + limit]

        # Batch query connection status for all authors in this page
        author_ids = list(set(s.author_id for _, s in page_scored))
        conns = await self.db.connection.find_many(
            where={
                "OR": [
                    {"sender_id": user_id, "receiver_id": {"in": author_ids}},
                    {"sender_id": {"in": author_ids}, "receiver_id": user_id},
                ]
            }
        )
        conn_map: dict[str, str] = {}
        for conn in conns:
            other_id = conn.receiver_id if conn.sender_id == user_id else conn.sender_id
            conn_map[other_id] = conn.status

        data = []
        for score, s in page_scored:
            liked = any(l.user_id == user_id for l in s.likes)
            data.append({
                "id": s.id,
                "author_id": s.author_id,
                "author_name": s.author.full_name if s.author else None,
                "author_photo": s.author.photo_url if s.author else None,
                "author_major": s.author.major if s.author else None,
                "author_faculty": s.author.faculty if s.author else None,
                "connection_status": conn_map.get(s.author_id),
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "likes_count": len(s.likes),
                "comments_count": len(s.comments),
                "liked_by_me": liked,
                "match_score": int(score * 100),
                "created_at": s.created_at.isoformat(),
            })

        await cache.set(cache_key, {"data": data, "total": total}, ttl=60)
        return data, total

    async def get_following_feed(self, user_id: str, page: int, limit: int) -> tuple[list[ShowcaseData], int]:
        connected = await self.db.connection.find_many(
            where={
                "OR": [
                    {"sender_id": user_id, "status": "accepted"},
                    {"receiver_id": user_id, "status": "accepted"},
                ]
            }
        )
        connected_ids = set()
        for c in connected:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        if not connected_ids:
            return [], 0

        total = await self.db.showcase.count(where={"author_id": {"in": list(connected_ids)}})
        offset = (page - 1) * limit
        showcases = await self.db.showcase.find_many(
            where={"author_id": {"in": list(connected_ids)}},
            order={"created_at": "desc"},
            skip=offset,
            take=limit,
            include={"author": True, "likes": True, "comments": True},
        )

        data = []
        for s in showcases:
            liked = any(l.user_id == user_id for l in s.likes)
            data.append({
                "id": s.id,
                "author_id": s.author_id,
                "author_name": s.author.full_name if s.author else None,
                "author_photo": s.author.photo_url if s.author else None,
                "author_major": s.author.major if s.author else None,
                "author_faculty": s.author.faculty if s.author else None,
                "connection_status": "accepted",
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "likes_count": len(s.likes),
                "comments_count": len(s.comments),
                "liked_by_me": liked,
                "match_score": 0,
                "created_at": s.created_at.isoformat(),
            })

        return data, total

    async def get_mine(self, user_id: str) -> list[ShowcaseData]:
        showcases = await self.db.showcase.find_many(
            where={"author_id": user_id},
            order={"created_at": "desc"},
            include={"likes": True, "comments": True},
        )
        return [{
            "id": s.id,
            "content": s.content,
            "media_urls": s.media_urls,
            "tags": s.tags,
            "likes_count": len(s.likes),
            "comments_count": len(s.comments),
            "created_at": s.created_at.isoformat(),
        } for s in showcases]

    async def get_detail(self, showcase_id: str, user_id: str) -> ShowcaseData:
        showcase = await self.db.showcase.find_unique(
            where={"id": showcase_id},
            include={
                "author": True,
                "likes": {"include": {"user": True}},
                "comments": {
                    "include": {"user": True, "replies": {"include": {"user": True}}},
                },
            }
        )
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        liked = any(l.user_id == user_id for l in showcase.likes)

        top_level = [c for c in showcase.comments if c.parent_id is None]
        top_level.sort(key=lambda c: c.created_at)

        comments_data = []
        for c in top_level:
            replies = sorted(c.replies, key=lambda r: r.created_at)
            replies_data = [{
                "id": r.id,
                "user_id": r.user_id,
                "full_name": r.user.full_name if r.user else None,
                "photo_url": r.user.photo_url if r.user else None,
                "content": r.content,
                "created_at": r.created_at.isoformat(),
            } for r in replies]
            comments_data.append({
                "id": c.id,
                "user_id": c.user_id,
                "full_name": c.user.full_name if c.user else None,
                "photo_url": c.user.photo_url if c.user else None,
                "content": c.content,
                "replies": replies_data,
                "created_at": c.created_at.isoformat(),
            })

        return {
            "id": showcase.id,
            "author_id": showcase.author_id,
            "author_name": showcase.author.full_name if showcase.author else None,
            "author_photo": showcase.author.photo_url if showcase.author else None,
            "content": showcase.content,
            "media_urls": showcase.media_urls,
            "tags": showcase.tags,
            "likes_count": len(showcase.likes),
            "liked_by_me": liked,
            "comments": comments_data,
            "created_at": showcase.created_at.isoformat(),
        }

    async def like(self, showcase_id: str, user_id: str):
        showcase = await self.db.showcase.find_unique(
            where={"id": showcase_id},
            include={"author": True},
        )
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        try:
            await self.db.showcaselike.create(data={"showcase_id": showcase_id, "user_id": user_id})
        except Exception:
            raise HTTPException(status_code=400, detail="Anda sudah menyukai showcase ini")

        if showcase.author_id != user_id:
            liker = await self.db.user.find_unique(where={"id": user_id})
            await notify(
                self.db, showcase.author_id, NOTIF_LIKE,
                "Seseorang menyukai postingan Anda",
                f"{liker.full_name} menyukai postingan '{showcase.content[:20]}...'",
                f"/showcase/{showcase_id}",
            )

    async def unlike(self, showcase_id: str, user_id: str):
        like = await self.db.showcaselike.find_first(
            where={"showcase_id": showcase_id, "user_id": user_id}
        )
        if not like:
            raise HTTPException(status_code=404, detail="Anda belum menyukai showcase ini")
        await self.db.showcaselike.delete(where={"id": like.id})

    async def comment(self, showcase_id: str, user_id: str, content: str, parent_id: int | None):
        showcase = await self.db.showcase.find_unique(where={"id": showcase_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

        comment = await self.db.showcasecomment.create(data={
            "showcase_id": showcase_id,
            "user_id": user_id,
            "content": content,
            "parent_id": parent_id,
        })

        commenter = await self.db.user.find_unique(where={"id": user_id})

        if showcase.author_id != user_id:
            await notify(
                self.db, showcase.author_id, NOTIF_COMMENT,
                "Seseorang mengomentari postingan Anda",
                f"{commenter.full_name} mengomentari: '{content[:30]}'",
                f"/showcase/{showcase_id}",
            )

        if parent_id:
            parent = await self.db.showcasecomment.find_unique(where={"id": parent_id})
            if parent and parent.user_id != user_id:
                await notify(
                    self.db, parent.user_id, NOTIF_COMMENT,
                    "Seseorang membalas komentar Anda",
                    f"{commenter.full_name} membalas komentar Anda.",
                    f"/showcase/{showcase_id}",
                )

        return comment

    async def get_share_link(self, showcase_id: str) -> str:
        showcase = await self.db.showcase.find_unique(where={"id": showcase_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        import os
        app_url = os.getenv("APP_URL", "https://rembugan.app")
        return f"{app_url}/s/{showcase_id}"

    async def share_to_user(self, showcase_id: str, sender_id: str, receiver_id: str):
        import os
        showcase = await self.db.showcase.find_unique(where={"id": showcase_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        receiver = await self.db.user.find_unique(where={"id": receiver_id})
        if not receiver:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        app_url = os.getenv("APP_URL", "https://rembugan.app")
        link = f"{app_url}/s/{showcase_id}"
        sender = await self.db.user.find_unique(where={"id": sender_id})
        content = f"{sender.full_name} membagikan postingan: {link}" if sender else f"Membagikan postingan: {link}"

        await self.db.message.create(data={"content": content, "sender_id": sender_id, "receiver_id": receiver_id})

        await notify(
            self.db, receiver_id, NOTIF_CHAT,
            "Postingan dibagikan ke Anda",
            content[:60],
            f"/chat/dm_{sender_id}_{receiver_id}",
        )

        return link
