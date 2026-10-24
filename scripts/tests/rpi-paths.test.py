#!/usr/bin/env python3
"""Guard the documentation paths shipped with the portable RPI commands."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
SKILL = ROOT / "lefant/rpi"


class RpiDocumentationPaths(unittest.TestCase):
    def test_bundled_instructions_use_docs(self):
        for path in SKILL.rglob("*.md"):
            with self.subTest(path=path.relative_to(ROOT)):
                text = path.read_text()
                self.assertNotIn("thoughts/", text)
        for command in ("research_codebase", "create_plan", "implement_plan"):
            with self.subTest(command=command):
                path = SKILL / "references" / f"{command}.md"
                text = path.read_text()
                self.assertTrue(text.startswith(f"# {command}\n"))
                self.assertIn("../SKILL.md#documentation-paths", text)
                area = "research" if command == "research_codebase" else "plans"
                self.assertIn(f"docs/{area}/", text)

    def test_research_paths_include_topic_directory(self):
        text = (SKILL / "references/research_codebase.md").read_text()
        paths = re.findall(r"docs/research/[^`\s]+", text)
        self.assertGreaterEqual(len(paths), 4)
        for path in paths:
            with self.subTest(path=path):
                self.assertRegex(path, r"^docs/research/[^/]+/research\.md$")
        self.assertIn("2025-01-08-ENG-1478-parent-child-tracking/research.md", text)
        self.assertIn("2025-01-08-authentication-flow/research.md", text)

    def test_plan_template_links_resolve_under_docs(self):
        text = (SKILL / "references/create_plan.md").read_text()
        # A plan is stored in docs/plans/, not beside the skill reference.
        base = Path("/documentation/docs/plans")
        links = re.findall(r"\[(?:Ticket|Research)\]\(([^)]+)\)", text)
        self.assertEqual(len(links), 2)
        resolved = [(base / link).resolve().as_posix() for link in links]
        self.assertEqual(resolved, [
            "/documentation/docs/tickets/eng_XXXX.md",
            "/documentation/docs/research/YYYY-MM-DD-<topic>/research.md",
        ])


if __name__ == "__main__":
    unittest.main()
