from app.services.sync import should_apply_remote_card, should_apply_remote_view

def test_remote_newer_card_wins():
    assert should_apply_remote_card(100, 200, tombstoned=False) is True

def test_remote_older_card_loses():
    assert should_apply_remote_card(300, 200, tombstoned=False) is False

def test_tombstone_never_resurrects():
    assert should_apply_remote_card(None, 999, tombstoned=True) is False

def test_missing_local_accepts_remote():
    assert should_apply_remote_card(None, 1, tombstoned=False) is True

def test_view_max_wins():
    assert should_apply_remote_view(5, 9) is True
    assert should_apply_remote_view(9, 5) is False

