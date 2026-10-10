#!/usr/bin/env python3
"""Contract and failure tests for the public-release Homebrew updater."""

import copy
import hashlib
import io
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock

import update_kilo_proxy as updater


TAG_OBJECT = "1" * 40
COMMIT = "2" * 40
TAP = Path(__file__).resolve().parent.parent


def fixture(version="0.56.3"):
    payloads = {name: f"public binary {name}\n".encode() for name in updater.package_names(version)}
    manifest = "".join(f"{hashlib.sha256(payload).hexdigest()}  {name}\n" for name, payload in sorted(payloads.items()))
    payloads["SHA256SUMS.txt"] = manifest.encode()
    release = {
        "id": 407990802,
        "tag_name": f"v{version}",
        "html_url": f"{updater.RELEASES}/tag/v{version}",
        "published_at": "2026-10-09T14:22:33Z",
        "draft": False,
        "prerelease": False,
        "assets": [{"name": name, "id": index + 1, "size": len(body),
                    "digest": f"sha256:{hashlib.sha256(body).hexdigest()}", "state": "uploaded",
                    "browser_download_url": f"{updater.RELEASES}/download/v{version}/{name}"}
                   for index, (name, body) in enumerate(sorted(payloads.items()))],
    }
    return release, payloads


def metadata(version="0.56.3"):
    release, _ = fixture(version)
    return updater.release_metadata(release, TAG_OBJECT, COMMIT)


def tag_api(release):
    def get_json(url):
        if url in (f"{updater.API}/releases/latest", f"{updater.API}/releases/{release['id']}"):
            return copy.deepcopy(release)
        if url == f"{updater.API}/git/ref/tags/{release['tag_name']}":
            return {"ref": f"refs/tags/{release['tag_name']}", "object": {"type": "tag", "sha": TAG_OBJECT}}
        if url == f"{updater.API}/git/tags/{TAG_OBJECT}":
            return {"sha": TAG_OBJECT, "tag": release["tag_name"], "object": {"type": "commit", "sha": COMMIT}}
        raise AssertionError(f"Unexpected API request: {url}")
    return get_json


def downloader(payloads, calls=None):
    def download(url, limit, label, sink=None):
        if calls is not None:
            calls.append(label)
        body = payloads[label]
        if sink is not None:
            # Exercise incremental hashing and exact byte counting.
            for position in range(0, len(body), 7):
                sink(body[position:position + 7])
            return b""
        return body
    return download


class ReleaseValidationTests(unittest.TestCase):
    def setUp(self):
        self.release, self.payloads = fixture()

    def rejected(self, change, pattern):
        change(self.release)
        with self.assertRaisesRegex(updater.VerificationError, pattern):
            updater.release_metadata(self.release, TAG_OBJECT, COMMIT)

    def test_exact_ten_packages_and_manifest(self):
        value = updater.release_metadata(self.release, TAG_OBJECT, COMMIT)
        self.assertEqual(len(value["assets"]), 11)
        self.assertEqual(value, updater.validate_saved(value))
        self.assertEqual(value["commit"], COMMIT)

    def test_drafts_and_prereleases_are_skipped(self):
        for field in ("draft", "prerelease"):
            with self.subTest(field=field):
                self.assertIsNone(updater.release_metadata({field: True}, TAG_OBJECT, COMMIT))

    def test_stability_flags_must_be_explicit(self):
        self.rejected(lambda release: release.pop("draft"), "flags missing")

    def test_semver_injection_is_rejected(self):
        for version in ('0.56.3";system("false")', "0.56.3-beta.1", "00.56.3", "0.56", "0.56.3+build", "0.56.3\n"):
            with self.subTest(version=version), self.assertRaises(updater.VerificationError):
                updater.parse_version(version)

    def test_extra_asset_is_rejected(self):
        self.rejected(lambda release: release["assets"].append(copy.deepcopy(release["assets"][0])), "exactly ten")

    def test_missing_asset_is_rejected(self):
        self.rejected(lambda release: release["assets"].pop(), "exactly ten")

    def test_duplicate_asset_is_rejected(self):
        self.rejected(lambda release: release["assets"].__setitem__(1, release["assets"][0]), "duplicate")

    def test_unknown_asset_path_is_rejected(self):
        self.rejected(lambda release: release["assets"][0].update(name="../../Formula/aisi.rb"), "Unexpected")

    def test_unuploaded_asset_is_rejected(self):
        self.rejected(lambda release: release["assets"][0].update(state="new"), "not uploaded")

    def test_missing_or_wrong_digest_is_rejected(self):
        for digest in (None, "sha256:" + "g" * 64, "sha512:" + "0" * 64):
            with self.subTest(digest=digest):
                release = copy.deepcopy(self.release)
                release["assets"][0]["digest"] = digest
                with self.assertRaisesRegex(updater.VerificationError, "SHA256"):
                    updater.release_metadata(release, TAG_OBJECT, COMMIT)

    def test_zero_boolean_and_oversized_asset_sizes_are_rejected(self):
        for size in (0, True, updater.MAX_ASSET_BYTES + 1):
            with self.subTest(size=size):
                release = copy.deepcopy(self.release)
                release["assets"][1]["size"] = size
                with self.assertRaisesRegex(updater.VerificationError, "asset size"):
                    updater.release_metadata(release, TAG_OBJECT, COMMIT)

    def test_release_url_identity_is_checked(self):
        self.rejected(lambda release: release.update(html_url="https://github.com/other/repo/releases/tag/v0.56.3"), "Release URL")

    def test_asset_url_identity_is_checked(self):
        self.rejected(lambda release: release["assets"][0].update(browser_download_url="https://evil.invalid/package"), "Asset URL")

    def test_ids_cannot_be_boolean(self):
        self.rejected(lambda release: release.update(id=True), "release ID")

    def test_saved_metadata_is_canonical_and_no_extra_fields_allowed(self):
        value = metadata()
        value["unexpected"] = "not accepted"
        with self.assertRaisesRegex(updater.VerificationError, "metadata fields"):
            updater.validate_saved(value)

    def test_saved_version_must_match_asset_names_and_tag(self):
        value = metadata()
        value["version"] = "0.56.4"
        with self.assertRaisesRegex(updater.VerificationError, "canonical"):
            updater.validate_saved(value)


class TagTests(unittest.TestCase):
    def test_annotated_tag_is_resolved(self):
        release, _ = fixture()
        self.assertEqual(updater.resolve_tag("v0.56.3", tag_api(release)), (TAG_OBJECT, COMMIT))

    def test_lightweight_tag_is_rejected(self):
        get_json = mock.Mock(return_value={"ref": "refs/tags/v0.56.3", "object": {"type": "commit", "sha": COMMIT}})
        with self.assertRaisesRegex(updater.VerificationError, "annotated"):
            updater.resolve_tag("v0.56.3", get_json)
        self.assertEqual(get_json.call_count, 1)

    def test_reference_identity_is_checked(self):
        get_json = mock.Mock(return_value={"ref": "refs/heads/main", "object": {"type": "tag", "sha": TAG_OBJECT}})
        with self.assertRaisesRegex(updater.VerificationError, "reference identity"):
            updater.resolve_tag("v0.56.3", get_json)

    def test_tag_object_identity_is_checked(self):
        release, _ = fixture()
        base = tag_api(release)
        def changed(url):
            value = base(url)
            if "/git/tags/" in url:
                value["sha"] = "3" * 40
            return value
        with self.assertRaisesRegex(updater.VerificationError, "object identity"):
            updater.resolve_tag("v0.56.3", changed)

    def test_tag_name_is_checked(self):
        release, _ = fixture()
        base = tag_api(release)
        def changed(url):
            value = base(url)
            if "/git/tags/" in url:
                value["tag"] = "v0.56.2"
            return value
        with self.assertRaisesRegex(updater.VerificationError, "tag name"):
            updater.resolve_tag("v0.56.3", changed)

    def test_nested_tag_cycles_are_rejected(self):
        values = [
            {"ref": "refs/tags/v0.56.3", "object": {"type": "tag", "sha": TAG_OBJECT}},
            {"sha": TAG_OBJECT, "tag": "v0.56.3", "object": {"type": "tag", "sha": TAG_OBJECT}},
        ]
        with self.assertRaisesRegex(updater.VerificationError, "cycle"):
            updater.resolve_tag("v0.56.3", mock.Mock(side_effect=values))

    def test_blob_target_is_rejected(self):
        values = [
            {"ref": "refs/tags/v0.56.3", "object": {"type": "tag", "sha": TAG_OBJECT}},
            {"sha": TAG_OBJECT, "tag": "v0.56.3", "object": {"type": "blob", "sha": COMMIT}},
        ]
        with self.assertRaisesRegex(updater.VerificationError, "commit"):
            updater.resolve_tag("v0.56.3", mock.Mock(side_effect=values))


class DownloadTests(unittest.TestCase):
    def setUp(self):
        self.release, self.payloads = fixture()
        self.metadata = metadata()

    def test_all_eleven_assets_are_streamed_and_verified(self):
        calls = []
        updater.verify_downloads(self.metadata, downloader(self.payloads, calls))
        self.assertEqual(sorted(calls), sorted(self.payloads))

    def test_archive_tampering_is_rejected_even_with_same_size(self):
        name = updater.package_names("0.56.3")[0]
        self.payloads[name] = b"!" + self.payloads[name][1:]
        with self.assertRaisesRegex(updater.VerificationError, "digest differs"):
            updater.verify_downloads(self.metadata, downloader(self.payloads))

    def test_short_archive_is_rejected(self):
        name = updater.package_names("0.56.3")[0]
        self.payloads[name] = self.payloads[name][:-1]
        with self.assertRaisesRegex(updater.VerificationError, "size differs"):
            updater.verify_downloads(self.metadata, downloader(self.payloads))

    def test_long_archive_is_rejected_during_streaming(self):
        name = updater.package_names("0.56.3")[0]
        self.payloads[name] += b"!"
        with self.assertRaisesRegex(updater.VerificationError, "larger"):
            updater.verify_downloads(self.metadata, downloader(self.payloads))

    def test_manifest_hash_must_equal_github_digest(self):
        body = self.payloads["SHA256SUMS.txt"].replace(b"  kilo-proxy-", b"  other-proxy-", 1)
        with self.assertRaisesRegex(updater.VerificationError, "differ from GitHub"):
            updater.parse_manifest(body, self.metadata)

    def test_manifest_duplicate_is_rejected(self):
        body = self.payloads["SHA256SUMS.txt"]
        with self.assertRaisesRegex(updater.VerificationError, "Duplicate"):
            updater.parse_manifest(body + body.splitlines()[0] + b"\n", self.metadata)

    def test_manifest_path_traversal_and_non_ascii_are_rejected(self):
        for body in (b"0" * 64 + b"  ../file\n", b"\xff\n"):
            with self.subTest(body=body), self.assertRaises(updater.VerificationError):
                updater.parse_manifest(body, self.metadata)

    def test_manifest_own_github_digest_is_checked(self):
        self.metadata["assets"][0]["sha256"] = "0" * 64  # sorted: SHA256SUMS.txt first
        with self.assertRaisesRegex(updater.VerificationError, "digest differs"):
            updater.verify_downloads(self.metadata, downloader(self.payloads))

    def test_requests_never_send_authorization(self):
        response = io.BytesIO(b"public")
        response.geturl = lambda: f"{updater.RELEASES}/download/v0.56.3/test"
        with mock.patch.dict("os.environ", {"GH_TOKEN": "secret", "GITHUB_TOKEN": "secret"}), mock.patch.object(updater.urllib.request, "urlopen", return_value=response) as opening:
            self.assertEqual(updater.fetch(f"{updater.RELEASES}/download/v0.56.3/test", 6, "test"), b"public")
        request = opening.call_args.args[0]
        self.assertNotIn("Authorization", request.headers)
        self.assertNotIn("secret", str(request.headers))

    def test_response_bound_is_enforced(self):
        response = io.BytesIO(b"oversized")
        response.geturl = lambda: f"{updater.RELEASES}/download/v0.56.3/test"
        with mock.patch.object(updater.urllib.request, "urlopen", return_value=response), self.assertRaisesRegex(updater.VerificationError, "allowed size"):
            updater.fetch(f"{updater.RELEASES}/download/v0.56.3/test", 3, "test")

    def test_api_metadata_can_use_token_but_refuses_redirects(self):
        response = io.BytesIO(b"{}")
        response.geturl = lambda: f"{updater.API}/releases/latest"
        opener = mock.Mock()
        opener.open.return_value = response
        with mock.patch.dict("os.environ", {"GH_TOKEN": "metadata-only-token"}), mock.patch.object(updater.urllib.request, "build_opener", return_value=opener) as build:
            self.assertEqual(updater.fetch_json(f"{updater.API}/releases/latest"), {})
        request = opener.open.call_args.args[0]
        self.assertEqual(request.headers["Authorization"], "Bearer metadata-only-token")
        handler = build.call_args.args[0]
        with self.assertRaisesRegex(updater.VerificationError, "must not redirect"):
            handler.redirect_request(request, None, 302, "Found", {}, "https://evil.invalid/")

    def test_metadata_auth_cannot_target_download_hosts(self):
        with self.assertRaisesRegex(updater.VerificationError, "only be used"):
            updater.fetch(f"{updater.RELEASES}/download/v0.56.3/test", 3, "test", authenticate_api=True)

    def test_untrusted_request_or_final_origin_is_rejected(self):
        with self.assertRaisesRegex(updater.VerificationError, "request origin"):
            updater.fetch("https://evil.invalid/test", 3, "test")
        response = io.BytesIO(b"bad")
        response.geturl = lambda: "http://internal.invalid/test"
        with mock.patch.object(updater.urllib.request, "urlopen", return_value=response), self.assertRaisesRegex(updater.VerificationError, "redirect"):
            updater.fetch(f"{updater.RELEASES}/download/v0.56.3/test", 3, "test")


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        shutil.copytree(TAP / "templates", self.root / "templates")
        (self.root / "Formula").mkdir()
        (self.root / "Formula/kilo-proxy-desktop.rb").write_text('''class KiloProxyDesktop < Formula
  version "0.56.2"
  url "https://github.com/rosseca/kilo-proxy.git",
      tag: "v0.56.2",
      revision: "0000000000000000000000000000000000000000"
  depends_on "go" => :build
end
''')
        (self.root / "Formula/aisi.rb").write_text("AISI must remain unchanged\n")
        self.release, self.payloads = fixture()

    def install_fixture(self):
        files = updater.render_files(self.root, metadata())
        updater.write_files(self.root, files)

    def snapshot(self):
        return {str(path.relative_to(self.root)): path.read_bytes() for path in self.root.rglob("*") if path.is_file()}

    def test_first_update_verifies_then_generates_all_files_and_preserves_aisi(self):
        calls = []
        self.assertTrue(updater.update(self.root, tag_api(self.release), downloader(self.payloads, calls)))
        self.assertEqual(len(calls), 11)
        updater.check_files(self.root, metadata())
        self.assertEqual((self.root / "Formula/aisi.rb").read_text(), "AISI must remain unchanged\n")
        desktop = (self.root / "Formula/kilo-proxy-desktop.rb").read_text()
        self.assertIn(f'revision: "{COMMIT}"', desktop)
        self.assertIn('depends_on "go" => :build', desktop)

    def test_same_verified_version_is_noop_without_downloading(self):
        self.install_fixture()
        previous = self.snapshot()
        download = mock.Mock(side_effect=AssertionError("No repeated downloads"))
        self.assertFalse(updater.update(self.root, tag_api(self.release), download))
        self.assertEqual(self.snapshot(), previous)
        download.assert_not_called()

    def test_same_version_modified_asset_is_rejected(self):
        self.install_fixture()
        previous = self.snapshot()
        self.release["assets"][1]["digest"] = "sha256:" + "0" * 64
        with self.assertRaisesRegex(updater.VerificationError, "manual review"):
            updater.update(self.root, tag_api(self.release), mock.Mock())
        self.assertEqual(self.snapshot(), previous)

    def test_same_version_recreated_release_is_rejected(self):
        self.install_fixture()
        self.release["id"] += 1
        with self.assertRaisesRegex(updater.VerificationError, "manual review"):
            updater.update(self.root, tag_api(self.release), mock.Mock())

    def test_downgrade_is_rejected(self):
        self.install_fixture()
        old, payloads = fixture("0.56.2")
        with self.assertRaisesRegex(updater.VerificationError, "downgrade"):
            updater.update(self.root, tag_api(old), downloader(payloads))

    def test_version_order_is_numeric(self):
        self.assertTrue(updater.check_transition(metadata("0.56.9"), metadata("0.56.10")))

    def test_download_failure_never_writes_outputs(self):
        previous = self.snapshot()
        self.payloads[updater.package_names("0.56.3")[-1]] += b"bad"
        with self.assertRaises(updater.VerificationError):
            updater.update(self.root, tag_api(self.release), downloader(self.payloads))
        self.assertEqual(self.snapshot(), previous)

    def test_tag_movement_during_download_never_writes_outputs(self):
        previous = self.snapshot()
        original = tag_api(self.release)
        references = 0
        def get_json(url):
            nonlocal references
            data = original(url)
            if "/git/ref/" in url:
                references += 1
            if references > 1 and "/git/tags/" in url:
                data["object"]["sha"] = "3" * 40
            return data
        with self.assertRaisesRegex(updater.VerificationError, "tag changed"):
            updater.update(self.root, get_json, downloader(self.payloads))
        self.assertEqual(self.snapshot(), previous)

    def test_asset_movement_during_download_never_writes_outputs(self):
        previous = self.snapshot()
        original = tag_api(self.release)
        def get_json(url):
            data = original(url)
            if url == f"{updater.API}/releases/{self.release['id']}":
                data["assets"][1]["size"] += 1
            return data
        with self.assertRaisesRegex(updater.VerificationError, "assets changed"):
            updater.update(self.root, get_json, downloader(self.payloads))
        self.assertEqual(self.snapshot(), previous)

    def test_prerelease_does_not_resolve_tag_or_write(self):
        previous = self.snapshot()
        get_json = mock.Mock(return_value={"prerelease": True})
        self.assertFalse(updater.update(self.root, get_json, mock.Mock()))
        self.assertEqual(get_json.call_count, 1)
        self.assertEqual(self.snapshot(), previous)

    def test_offline_check_detects_generated_tampering(self):
        self.install_fixture()
        (self.root / "Casks/kilo-proxy.rb").write_text("tampered\n")
        with self.assertRaisesRegex(updater.VerificationError, "out of date"):
            updater.check_files(self.root, metadata())

    def test_offline_check_never_calls_network_or_writes(self):
        self.install_fixture()
        previous = self.snapshot()
        with mock.patch.object(updater.urllib.request, "urlopen", side_effect=AssertionError("Offline check")):
            self.assertEqual(updater.main(["--root", str(self.root), "--check"]), 0)
        self.assertEqual(self.snapshot(), previous)

    def test_desktop_contract_failure_never_changes_other_files(self):
        (self.root / "Formula/kilo-proxy-desktop.rb").write_text("unknown source\n")
        previous = self.snapshot()
        with self.assertRaisesRegex(updater.VerificationError, "fixed Kilo"):
            updater.update(self.root, tag_api(self.release), mock.Mock())
        self.assertEqual(self.snapshot(), previous)

    def test_render_preserves_desktop_other_version_mentions(self):
        source = (self.root / "Formula/kilo-proxy-desktop.rb").read_text() + '# unrelated tag: "v0.56.2"\n'
        result = updater.render_desktop(source, metadata())
        self.assertIn('# unrelated tag: "v0.56.2"', result)

    def test_desktop_homebrew_aligned_fields_are_preserved(self):
        source = (self.root / "Formula/kilo-proxy-desktop.rb").read_text().replace('tag: "', 'tag:      "')
        result = updater.render_desktop(source, metadata())
        self.assertIn('      tag:      "v0.56.3",', result)
        self.assertIn(f'      revision: "{COMMIT}"', result)


if __name__ == "__main__":
    unittest.main()
