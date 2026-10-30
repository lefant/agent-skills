"""Offline CLI regressions for vendor replacement and cached checkout safety."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[2]
GIT = shutil.which("git")


def run(*args, **kwargs):
    return subprocess.run(args, text=True, capture_output=True, **kwargs)


def snapshot(path):
    return {
        str(p.relative_to(path)): (p.read_bytes(), p.stat().st_mode)
        for p in path.rglob("*") if p.is_file()
    }


class LibrarianSafety(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.cache = self.root / "cache"
        self.env = {**os.environ, "LIBRARIAN_CACHE_ROOT": str(self.cache),
                    "GIT_ALLOW_PROTOCOL": "file"}

    def repo(self, path, origin="https://github.com/owner/project.git"):
        run(GIT, "init", "-q", str(path), check=True)
        run(GIT, "-C", str(path), "remote", "add", "origin", origin, check=True)
        (path / ".git/librarian-last-fetch").write_text(str(int(time.time())))
        return path

    def checkout(self, reference):
        return run("bash", str(ROOT / "vendor/mitsuhiko/librarian/checkout.sh"),
                   reference, "--path-only", env=self.env)

    def test_unsafe_paths_leave_victim_untouched(self):
        victim = self.repo(self.root / "victim", "https://example.org/private/repo.git")
        before = snapshot(victim)
        for reference in ("https://github.com/../../victim", "../victim",
                          "https://../owner/project", "owner/./project", "owner//project"):
            with self.subTest(reference=reference):
                self.assertNotEqual(self.checkout(reference).returncode, 0)
                self.assertEqual(snapshot(victim), before)
        self.assertFalse(self.cache.exists())
        for relative in ("github.com", "github.com/owner", "github.com/owner/project",
                         "github.com/owner/project/.git"):
            with self.subTest(symlink=relative):
                shutil.rmtree(self.cache, ignore_errors=True)
                link = self.cache / relative
                link.parent.mkdir(parents=True)
                link.symlink_to(victim, target_is_directory=True)
                self.assertNotEqual(self.checkout("owner/project").returncode, 0)
                self.assertEqual(snapshot(victim), before)

    def test_existing_checkout_is_reused_only_for_matching_origin(self):
        path = self.repo(self.cache / "github.com/owner/project",
                         "git@github.com:owner/project.git")
        before = snapshot(path)
        for reference in ("owner/project", "github.com/owner/project",
                          "https://github.com/owner/project.git",
                          "ssh://git@github.com/owner/project",
                          "https://github.com/owner/project/tree/main/src"):
            with self.subTest(reference=reference):
                result = self.checkout(reference)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.strip(), str(path))
                self.assertEqual(snapshot(path), before)
        run(GIT, "-C", str(path), "remote", "set-url", "origin",
            "https://github.com/someone/else.git", check=True)
        before = snapshot(path)
        self.assertNotEqual(self.checkout("owner/project").returncode, 0)
        self.assertEqual(snapshot(path), before)
        run(GIT, "-C", str(path), "remote", "remove", "origin", check=True)
        before = snapshot(path)
        self.assertNotEqual(self.checkout("owner/project").returncode, 0)
        self.assertEqual(snapshot(path), before)


class VendorUpdateSafety(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.checkout = self.root / "checkout"
        for name in ("vendor", "lefant", "scripts"):
            shutil.copytree(ROOT / name, self.checkout / name)
        self.upstream = self.root / "upstream"
        shutil.copytree(ROOT / "vendor/hegeldev", self.upstream / "skills")
        (self.upstream / "LICENSE").write_text("Fixture license\n")
        run(GIT, "init", "-q", str(self.upstream), check=True)
        self.commit_upstream()
        # Redirect clone transport only; exercise real Git and sparse checkout offline.
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        wrapper = bin_dir / "git"
        wrapper.write_text('''#!/bin/bash
if [[ "$1" == clone ]]; then
    [[ "${FAIL_CLONE:-0}" == 0 ]] || exit 1
    exec "$REAL_GIT" clone --quiet "$UPSTREAM" "${@: -1}"
fi
exec "$REAL_GIT" "$@"
''')
        wrapper.chmod(0o755)
        mover = bin_dir / "mv"
        mover.write_text('''#!/bin/bash
if [[ "${FAIL_INSTALL:-0}" == 1 && "$1" == */staged/vendor ]]; then exit 1; fi
exec "$REAL_MV" "$@"
''')
        mover.chmod(0o755)
        self.env = {**os.environ, "PATH": f"{bin_dir}:{os.environ['PATH']}",
                    "REAL_GIT": GIT, "REAL_MV": shutil.which("mv"),
                    "UPSTREAM": str(self.upstream),
                    "GIT_ALLOW_PROTOCOL": "file"}

    def commit_upstream(self):
        run(GIT, "-C", str(self.upstream), "add", "-A", check=True)
        run(GIT, "-C", str(self.upstream), "-c", "user.name=Fixture",
            "-c", "user.email=fixture@example.invalid", "commit", "-qm", "fixture", check=True)

    def update(self, *repos):
        return run("bash", str(self.checkout / "scripts/update-vendor.sh"),
                   *(repos or ("hegeldev/hegel-skill",)), env=self.env)

    def assert_preserved_on_failure(self):
        before = snapshot(self.checkout / "vendor")
        result = self.update()
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(snapshot(self.checkout / "vendor"), before)
        self.assertEqual(list(self.checkout.glob(".vendor-update.*")), [])

    def test_failed_fetch_and_missing_skill_preserve_snapshot(self):
        self.env["FAIL_CLONE"] = "1"
        self.assert_preserved_on_failure()
        self.env.pop("FAIL_CLONE")
        license_file = self.upstream / "LICENSE"
        license_file.unlink()
        self.commit_upstream()
        self.assert_preserved_on_failure()
        license_file.write_text("Fixture license\n")
        shutil.rmtree(self.upstream / "skills/hegel-review")
        self.commit_upstream()
        self.assert_preserved_on_failure()

    def test_invalid_layout_and_patch_drift_preserve_snapshot(self):
        skill = self.upstream / "skills/hegel-review/SKILL.md"
        skill.write_text(skill.read_text().replace("name: hegel-review", "name: wrong-name"))
        self.commit_upstream()
        self.assert_preserved_on_failure()
        skill.write_text(skill.read_text().replace("name: wrong-name", "name: hegel-review"))
        self.commit_upstream()
        helper = self.checkout / "vendor/mitsuhiko/librarian/checkout.sh"
        helper.write_text(helper.read_text().replace('parsed="$(parse_repo "$repo_input")" || exit 2',
                                                    'parsed="changed parser"'))
        self.assert_preserved_on_failure()

    def test_failed_install_restores_previous_snapshot(self):
        self.env["FAIL_INSTALL"] = "1"
        self.assert_preserved_on_failure()

    def test_success_is_targeted_and_repeatable(self):
        vendor = self.checkout / "vendor"
        before = snapshot(vendor)
        run("patch", "-d", str(self.checkout), "-p1", "--batch", "--reverse",
            "-i", str(self.checkout / "scripts/patches/librarian-cache-safety.patch"), check=True)
        result = self.update()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        after = snapshot(vendor)
        changed = {p for p in before.keys() | after.keys() if before.get(p) != after.get(p)}
        self.assertEqual(changed, {"hegeldev/hegel/LICENSE", "hegeldev/hegel-review/LICENSE"})
        result = self.update()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(snapshot(vendor), after)
        result = self.update("unknown/repo")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(snapshot(vendor), after)


if __name__ == "__main__":
    unittest.main()
