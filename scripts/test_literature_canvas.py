"""Exercise the documented canvas commands in a temporary, bound research project."""
import json
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SKILLS = Path(__file__).resolve().parents[1] / "skills"
LITERATURE = SKILLS / "obsidian-literature-workflow"
BUILDER = LITERATURE / "scripts/build_literature_canvas.py"
KB = SKILLS / "obsidian-project-kb-core/scripts/project_kb.py"


class CanvasOutputTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name).resolve()
        self.repo = root / "study"
        self.vault = root / "vault"
        self.vault.mkdir()
        subprocess.run(["git", "init", "--quiet", str(self.repo)], check=True)
        subprocess.run(
            [sys.executable, "-B", str(KB), "bootstrap", "--cwd", str(self.repo),
             "--vault-path", str(self.vault), "--project-name", "Canvas Review"],
            check=True, stdout=subprocess.DEVNULL,
        )
        self.project = self.vault / "Research/canvas-review"
        self.paper = self.project / "Sources/Papers/example.md"
        self.paper.write_text("# Example paper\n", encoding="utf-8")
        self.default = self.project / "Maps/literature.canvas"
        self.presentation = self.project / "Maps/literature-main.canvas"

    def build(self, *options):
        output = subprocess.check_output(
            [sys.executable, "-B", str(BUILDER), "--cwd", str(self.repo), *options], text=True,
        )
        return Path(json.loads(output)["output"])

    def assert_paper_on_canvas(self, path, paper):
        canvas = json.loads(path.read_text(encoding="utf-8"))
        files = [node["file"] for node in canvas["nodes"] if node["type"] == "file"]
        self.assertIn(paper.relative_to(self.vault).as_posix(), files)

    def move_node_by_hand(self, path):
        canvas = json.loads(path.read_text(encoding="utf-8"))
        canvas["nodes"][0]["x"] += 100
        path.write_text(json.dumps(canvas), encoding="utf-8")
        return path.read_bytes()

    def test_default_creates_only_the_working_canvas(self):
        self.assertEqual(self.build(), self.default)
        self.build()
        self.assertEqual(list(self.project.rglob("*.canvas")), [self.default])
        self.assert_paper_on_canvas(self.default, self.paper)

    def test_explicit_output_writes_a_copy_and_preserves_the_working_canvas(self):
        self.build()
        edited = self.move_node_by_hand(self.default)
        self.assertEqual(self.build("--output", "Maps/literature-main.canvas"), self.presentation)
        self.assert_paper_on_canvas(self.presentation, self.paper)
        self.assertEqual(self.default.read_bytes(), edited)

    def test_default_refresh_preserves_the_edited_presentation(self):
        self.build("--output", "Maps/literature-main.canvas")
        edited = self.move_node_by_hand(self.presentation)
        new_paper = self.paper.with_name("follow-up.md")
        new_paper.write_text("# Follow-up paper\n", encoding="utf-8")
        self.build()
        self.assert_paper_on_canvas(self.default, new_paper)
        self.assertEqual(self.presentation.read_bytes(), edited)


class CanvasGuidanceTest(unittest.TestCase):
    def test_literature_and_zotero_point_to_the_same_opt_in_rule(self):
        guide = LITERATURE / "references/CANVAS-WORKFLOW.md"
        _, heading, rest = guide.read_text(encoding="utf-8").partition("## Display rule\n")
        self.assertTrue(heading, "The display-rule links must lead to an existing heading")
        rule = rest.split("\n## ", 1)[0]
        self.assertRegex(rule, r"\bexplicit(?:ly)? (?:user )?request\w*\b")
        for entry in (LITERATURE / "SKILL.md", SKILLS / "zotero-obsidian-bridge/references/WORKFLOW.md"):
            with self.subTest(entry=entry):
                links = re.findall(r"\[[^\]]+\]\(([^)]+)#display-rule\)", entry.read_text(encoding="utf-8"))
                self.assertIn(guide, [(entry.parent / link).resolve() for link in links])


if __name__ == "__main__":
    unittest.main(verbosity=2)
