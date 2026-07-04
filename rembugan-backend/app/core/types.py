from typing import TypedDict, Optional
from datetime import datetime


class UserProfileData(TypedDict, total=False):
    id: str
    full_name: str
    handle: Optional[str]
    nim: Optional[str]
    faculty: Optional[str]
    major: Optional[str]
    bio: Optional[str]
    photo_url: Optional[str]
    cover_url: Optional[str]
    interest: Optional[str]
    email: Optional[str]
    email_verified: bool
    is_onboarded: bool
    skills: list[str]
    connection_count: int
    project_count: int


class ProjectData(TypedDict, total=False):
    id: int
    title: str
    description: str
    status: str
    category: Optional[str]
    required_skills: list[str]
    owner_id: str
    owner_name: Optional[str]
    member_count: int
    match_score: int
    is_owner: bool
    created_at: str


class WorkspaceData(TypedDict, total=False):
    id: str
    name: str
    description: Optional[str]
    user_role: str
    total_tasks: int
    done_tasks: int
    member_count: int
    members: list[dict]
    is_owned: bool
    applicants: int
    last_activity: str
    urgency: Optional[str]
    deadline: Optional[str]


class ShowcaseData(TypedDict, total=False):
    id: str
    author_id: str
    author_name: Optional[str]
    content: str
    media_urls: list[str]
    tags: list[str]
    likes_count: int
    comments_count: int
    liked_by_me: bool
    match_score: int
    created_at: str


class AuthData(TypedDict, total=False):
    access_token: str
    token_type: str
    user_id: str
    full_name: str
    handle: Optional[str]
    is_onboarded: bool
    email: Optional[str]
    nim: Optional[str]
    major: Optional[str]
    interest: Optional[str]


class TaskData(TypedDict, total=False):
    id: int
    title: str
    status: str
    assignees: list[dict]
    deadline: Optional[str]
    created_at: str


class MessageData(TypedDict, total=False):
    id: int
    content: str
    type: str
    sender_id: str
    sender_name: Optional[str]
    attachment_url: Optional[str]
    created_at: str
