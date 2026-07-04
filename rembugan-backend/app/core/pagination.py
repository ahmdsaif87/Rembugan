from dataclasses import dataclass
from fastapi import Query


@dataclass
class PageParams:
    page: int = 1
    limit: int = 10

    @property
    def skip(self) -> int:
        return (self.page - 1) * self.limit

    @property
    def take(self) -> int:
        return self.limit
