from fastapi import FastAPI
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.core.ratelimit import limiter
from app.routers import health
from app.routers import auth
from app.routers import cards
from app.routers import logs
from app.routers import settings
from app.routers import views
from app.routers import ai
from app.version import __version__


def create_app() -> FastAPI:
    app = FastAPI(title="JishoAnki API", version=__version__)
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    app.include_router(health.router)
    app.include_router(auth.router)
    app.include_router(cards.router)
    app.include_router(logs.router)
    app.include_router(settings.router)
    app.include_router(views.router)
    app.include_router(ai.router)
    return app


app = create_app()