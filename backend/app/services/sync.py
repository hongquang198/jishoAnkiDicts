def should_apply_remote_card(
        local_updated_at: int | None,
        remote_updated_at: int, tombstoned: bool) -> bool:
    """Return True if the remote card should overwrite local state."""
    if tombstoned:
        return False
    if local_updated_at is None:
        return True
    return remote_updated_at > local_updated_at

def should_apply_remote_view(
        local_count: int | None, remote_count: int) -> bool:
    if local_count is None:
        return True
    return remote_count > local_count