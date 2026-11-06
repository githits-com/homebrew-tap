"""Security and idempotence cases for the automatic publication boundary."""

import copy
import unittest

from select_publish_pr import BOT, FORMULA, select_pr


REPO = "githits-com/homebrew-tap"
SHA = "a" * 40


class SelectionTests(unittest.TestCase):
    def setUp(self):
        self.event = {"workflow_run": {"event": "pull_request", "conclusion": "success",
                                      "head_repository": {"full_name": REPO},
                                      "head_sha": SHA, "pull_requests": [{"number": 8}]}}
        self.pr = {"number": 8, "state": "open", "user": {"login": BOT}, "changed_files": 1,
                   "base": {"ref": "main"}, "head": {"sha": SHA, "repo": {"full_name": REPO}}}
        self.files = [{"filename": FORMULA, "status": "modified"}]
        self.calls = []

    def fetch(self, path):
        self.calls.append(path)
        return self.files if "/files?" in path else self.pr

    def select(self):
        return select_pr("workflow_run", self.event, REPO, self.fetch)

    def test_successful_app_formula_update_selects_exact_tested_head(self):
        self.assertEqual(self.select(), (8, SHA))
        self.assertEqual(len(self.calls), 2)

    def test_human_and_dependabot_prs_never_auto_publish(self):
        for login in ("maintainer", "dependabot[bot]", BOT.replace("bumper", "impostor")):
            with self.subTest(login=login):
                self.pr["user"]["login"] = login
                self.assertIsNone(self.select())

    def test_failed_cancelled_and_main_push_runs_do_not_query_prs(self):
        for key, value in (("conclusion", "failure"), ("conclusion", "cancelled"),
                           ("event", "push")):
            with self.subTest(key=key, value=value):
                event = copy.deepcopy(self.event)
                event["workflow_run"][key] = value
                self.assertIsNone(select_pr("workflow_run", event, REPO, self.fetch))
        self.assertEqual(self.calls, [])

    def test_missing_multiple_or_fork_pr_associations_skip(self):
        for prs in ([], [{"number": 8}, {"number": 9}]):
            self.event["workflow_run"]["pull_requests"] = prs
            self.assertIsNone(self.select())
        self.event["workflow_run"]["pull_requests"] = [{"number": 8}]
        self.event["workflow_run"]["head_repository"]["full_name"] = "fork/tap"
        self.assertIsNone(self.select())
        self.assertEqual(self.calls, [])

    def test_closed_pr_reruns_newer_heads_and_wrong_base_skip(self):
        for key, value in (("state", "closed"), ("changed_files", 2)):
            with self.subTest(key=key):
                pr = copy.deepcopy(self.pr)
                pr[key] = value
                self.assertIsNone(select_pr("workflow_run", self.event, REPO,
                                           lambda _: pr))
        self.pr["head"]["sha"] = "b" * 40
        self.assertIsNone(self.select())
        self.pr["head"]["sha"] = SHA
        self.pr["base"]["ref"] = "other"
        self.assertIsNone(self.select())

    def test_only_modified_formula_is_allowed(self):
        for files in ([{"filename": "README.md", "status": "modified"}],
                      [{"filename": ".github/workflows/tests.yml", "status": "modified"}],
                      [{"filename": FORMULA, "status": "removed"}], [],
                      self.files + [{"filename": "README.md", "status": "modified"}]):
            with self.subTest(files=files):
                self.files = files
                self.assertIsNone(self.select())

    def test_deleted_or_foreign_head_repository_skips(self):
        for repo in (None, {"full_name": "fork/tap"}):
            self.pr["head"]["repo"] = repo
            self.assertIsNone(self.select())

    def test_manual_label_allows_human_pr(self):
        self.pr["user"]["login"] = "maintainer"
        event = {"action": "labeled", "label": {"name": "pr-pull"}, "pull_request": self.pr}
        self.assertEqual(select_pr("pull_request_target", event, REPO, self.fetch), (8, SHA))
        event["label"]["name"] = "feature"
        self.assertIsNone(select_pr("pull_request_target", event, REPO, self.fetch))
        self.assertEqual(self.calls, [])

    def test_manual_dispatch_resolves_current_or_expected_head(self):
        event = {"inputs": {"pull_request": "8"}}
        self.assertEqual(select_pr("workflow_dispatch", event, REPO, self.fetch), (8, SHA))
        event["inputs"]["head_sha"] = "b" * 40
        self.assertEqual(select_pr("workflow_dispatch", event, REPO, self.fetch), (8, "b" * 40))
        for sha in ("invalid", SHA + "\nnumber=9"):
            event["inputs"]["head_sha"] = sha
            with self.assertRaises(ValueError):
                select_pr("workflow_dispatch", event, REPO, self.fetch)
        event["inputs"]["head_sha"] = SHA
        for number in ("0", "-1", "1; echo unsafe", "８"):
            event["inputs"]["pull_request"] = number
            with self.assertRaises(ValueError):
                select_pr("workflow_dispatch", event, REPO, self.fetch)


if __name__ == "__main__":
    unittest.main()
