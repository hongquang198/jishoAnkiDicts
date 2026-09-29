"""S03 contracts: Pydantic validates shapes and fills defaults.

Firestore accepted any JSON silently; these tests pin the opposite:
bad shapes fail fast, missing optionals get defaults, extras are ignored.
"""
import pytest
from pydantic import ValidationError

from app.models.schemas import (
    AiExplainIn,
    AuthLinkGoogle,
    BulkCards,
    CardIn,
    ReviewLogIn,
    UserSettingsIn,
    WordViewIn,
)


def test_card_requires_id():
    with pytest.raises(ValidationError):
        CardIn(word='no-id')


def test_card_defaults_fill():
    card = CardIn(id='a')
    assert (card.word, card.updated_at) == ('', 0)


def test_bulk_defaults_empty():
    assert BulkCards().cards == []


def test_view_and_log_shapes():
    assert WordViewIn(word='猫').view_count == 1
    assert ReviewLogIn(id='l1').reviewed_at == 0
    with pytest.raises(ValidationError):
        ReviewLogIn(card_id='no-id')


def test_settings_and_auth_shapes():
    assert UserSettingsIn().llm_model == 'gemini-3.5-flash-lite'
    assert AuthLinkGoogle(id_token='x').id_token == 'x'
    assert AiExplainIn(word='猫').model == 'gemini-3.5-flash-lite'


def test_extra_client_keys_ignored():
    # Full Flutter toMap()s carry more keys than the contract needs.
    card = CardIn(id='a', word='b', updated_at=1, is_favorite=1, deck='x')
    assert (card.id, card.word) == ('a', 'b')
