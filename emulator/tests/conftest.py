import subprocess

import pytest

from emuhelp import ROOT


@pytest.fixture(scope="session", autouse=True)
def build():
    """Builds the emulator and the stepper harness before any test runs."""
    r = subprocess.run(["make", "-s", "-C", str(ROOT / "emulator")],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
