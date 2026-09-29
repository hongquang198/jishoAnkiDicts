"""S04/S05 auth primitives: salted hashes and signed, expiring tokens.

Passwords are never stored (bcrypt + unique salt each call); identity rides
on stateless JWTs that die on their own (exp) and fail closed on tampering.
"""
from app.core.security import (
    hash_password,
    issue_access_token,
    parse_user_id,
    verify_password,
)


def test_password_verifies_and_wrong_fails():
    hashed = hash_password('secret123')
    assert verify_password('secret123', hashed) is True
    assert verify_password('wrong', hashed) is False


def test_same_password_different_hashes():
    # Unique salt per call: rainbow tables are worthless against this store.
    assert hash_password('same') != hash_password('same')


def test_token_round_trip():
    token = issue_access_token('u_123')
    assert parse_user_id(token) == 'u_123'


def test_bogus_token_rejected():
    assert parse_user_id('bogus') is None
    assert parse_user_id('') is None


def test_expired_token_rejected():
    token = issue_access_token('u_123', minutes=-1)
    assert parse_user_id(token) is None
