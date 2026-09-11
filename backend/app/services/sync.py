# FILE: app/services/sync.py
# WHAT: Pure last-write-wins merge helpers — no DB, no HTTP, fully testable.
# WHY: Conflict logic isolated from I/O (Clean Architecture) so unit tests in
#   tests/test_sync.py define DONE before any database code exists.
# FLUTTER COUNTERPART: UserDataRepositoryImpl.syncWithRemote (same rules).
# TUTOR SESSION: 11 — see backend/plan/00-tutor-sessions.md.
"""Pure sync helpers — no DB, no HTTP. Unit-testable LWW merge.

Mirrors `UserDataRepositoryImpl.syncWithRemote`: last-write-wins on
`updatedAt`, max-wins on `viewCount`, tombstones win over resurrection.
"""


def should_apply_remote_card(
    local_updated_at: int | None, remote_updated_at: int, tombstoned: bool
) -> bool:
    """Return True if the remote card should overwrite local state."""
    if tombstoned:
        return False
    if local_updated_at is None:
        return True
    return remote_updated_at > local_updated_at


def should_apply_remote_view(local_count: int | None, remote_count: int) -> bool:
    if local_count is None:
        return True
    return remote_count > local_count
