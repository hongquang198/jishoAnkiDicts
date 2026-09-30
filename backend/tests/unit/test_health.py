from fastapi.testclient import TestClient

from app.main import create_app
from app.version import __version__

def test_health_ok():
    client = TestClient(create_app())
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"status": "ok"}


def test_version_matches_source_of_truth():
    client = TestClient(create_app())
    res = client.get("/version")
    assert res.status_code == 200
    assert res.json()["version"] == __version__