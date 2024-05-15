from abc import ABC, abstractmethod
from typing import Generator
from pathlib import Path


@abstractmethod
def clean_path(path: Path) -> None:
    pass


class Indexer(ABC):
    @abstractmethod
    def index(self) -> Generator[Path, None, None]:
        pass

    def __init__(self, root: Path):
        self.root = root
