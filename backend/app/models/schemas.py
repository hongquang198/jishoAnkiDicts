from pydantic import BaseModel

# Why does this class only have 3 fields?
class CardIn(BaseModel):
    id: str
    word: str = ''
    updated_at: int = 0

class BulkCards(BaseModel):
    cards: list[CardIn] = []

# I followed the above class so only pick the primary fields
# But the client json sent will have more fields right?
class WordViewIn(BaseModel):
    word: str = ''
    view_count: int = 1
    first_viewed_at: int = 0
    last_viewed_at: int = 0

class BulkViews(BaseModel):
    views: list[WordViewIn] = []

class ReviewLogIn(BaseModel):
    id: str
    card_id: str = ''
    rating: str ='good'
    reviewed_at: int = 0

class BulkLogs(BaseModel):
    logs: list[ReviewLogIn] = []

class UserSettingsIn(BaseModel):
    llm_model: str = 'gemini-3.5-flash-lite'
    updated_at: int = 0

class AuthLinkGoogle(BaseModel):
    id_token: str

class AiExplainIn(BaseModel):
    word: str
    source_lang: str = 'Tiếng Việt'
    model: str = 'gemini-3.5-flash-lite'

class AiGenerateIn(BaseModel):
    prompt: str
    model: str = 'gemini-3.5-flash-lite'