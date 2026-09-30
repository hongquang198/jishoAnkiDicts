from fastapi import APIRouter

from app.version import __version__

router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict:
    return {"status": "ok"}


@router.get("/version")
def version() -> dict:
    # Deploy verification: proves WHICH build answers (debugging deploys).
    return {"version": __version__, "api": "v1"}