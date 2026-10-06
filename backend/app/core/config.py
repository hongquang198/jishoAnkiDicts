from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', extra='ignore')

    jwt_secret: str = 'change-me-in-env'
    jwt_alg: str = 'HS256'
    access_token_minutes: int = 60
    refresh_token_days: int = 30
    database_url: str = 'sqlite:///./jisho.db'
    google_client_id: str = ''
    redis_url: str = 'redis://localhost:6379/0'
    gemini_api_key: str = ''
settings = Settings()