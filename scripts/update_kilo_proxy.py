#!/usr/bin/env python3
"""Verify a public stable Kilo Proxy release, then update this tap atomically.

Public downloads never carry credentials. An optional GitHub Actions token can
authenticate API metadata requests; those requests refuse all redirects.
--check is entirely offline and checks the committed generated files.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import string
import sys
import tempfile
from typing import Callable
import urllib.error
import urllib.parse
import urllib.request


REPOSITORY = "rosseca/kilo-proxy"
API = f"https://api.github.com/repos/{REPOSITORY}"
RELEASES = f"https://github.com/{REPOSITORY}/releases"
VERSION = re.compile(r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\Z")
SHA256 = re.compile(r"[0-9a-f]{64}\Z")
SHA1 = re.compile(r"[0-9a-f]{40}\Z")
MAX_ASSET_BYTES = 512 * 1024 * 1024
MAX_MANIFEST_BYTES = 64 * 1024
MAX_JSON_BYTES = 2 * 1024 * 1024
METADATA = "kilo-proxy-release.json"
GENERATED = ("Casks/kilo-proxy.rb", "Formula/kilo-proxy-headless.rb", "Formula/kilo-proxy-desktop.rb", METADATA)


class VerificationError(ValueError):
    """Untrusted or inconsistent release data. No files should be changed."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def parse_version(version: object) -> tuple[int, int, int]:
    require(isinstance(version, str) and len(version) <= 32 and VERSION.fullmatch(version) is not None, "Expected a stable numeric major.minor.patch version")
    return tuple(int(part) for part in version.split("."))


def package_names(version: str) -> list[str]:
    parse_version(version)
    return sorted(
        [f"kilo-proxy-{version}-{system}-{arch}.{'zip' if system in ('darwin', 'windows') else 'tar.gz'}"
         for system in ("darwin", "linux", "windows") for arch in ("amd64", "arm64")]
        + [f"kilo-proxy-headless-{version}-{system}-{arch}.tar.gz"
           for system in ("darwin", "linux") for arch in ("amd64", "arm64")]
    )


def public_url(url: str, hosts: set[str]) -> bool:
    try:
        parsed = urllib.parse.urlsplit(url)
        return (parsed.scheme == "https" and parsed.hostname in hosts and parsed.port is None
                and parsed.username is None and parsed.password is None and not parsed.fragment)
    except ValueError:
        return False


class NoMetadataRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise VerificationError("GitHub API metadata requests must not redirect")


def fetch(url: str, limit: int, label: str, sink: Callable[[bytes], None] | None = None,
          *, authenticate_api: bool = False) -> bytes:
    """Bound a public response; do not retain archives or print signed redirects."""
    require(public_url(url, {"github.com", "api.github.com"}), "Unexpected request origin")
    headers = {
        "Accept": "application/vnd.github+json" if url.startswith("https://api.github.com/") else "application/octet-stream",
        "User-Agent": "rosseca-homebrew-kilo-proxy-updater",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if authenticate_api:
        require(public_url(url, {"api.github.com"}), "Credentials may only be used for GitHub API metadata")
        token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
        if token:
            headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, headers=headers)
    # urllib's ordinary redirect handler can forward Authorization. Refusing
    # metadata redirects entirely keeps even a malformed API response harmless.
    opening = urllib.request.build_opener(NoMetadataRedirect()).open if authenticate_api else urllib.request.urlopen
    result = bytearray()
    total = 0
    try:
        with opening(request, timeout=60) as response:
            require(public_url(response.geturl(), {"api.github.com", "github.com", "release-assets.githubusercontent.com", "objects.githubusercontent.com"}), "Unexpected download redirect origin")
            while True:
                chunk = response.read(min(1024 * 1024, limit + 1 - total))
                if not chunk:
                    break
                total += len(chunk)
                require(total <= limit, f"{label} exceeds its allowed size")
                if sink is None:
                    result.extend(chunk)
                else:
                    sink(chunk)
    except urllib.error.HTTPError as exc:
        raise VerificationError(f"Unable to fetch {label}: HTTP {exc.code}") from None
    except (urllib.error.URLError, TimeoutError, OSError):
        raise VerificationError(f"Unable to fetch {label}") from None
    return bytes(result)


def fetch_json(url: str) -> dict:
    try:
        data = json.loads(fetch(url, MAX_JSON_BYTES, "GitHub metadata", authenticate_api=True))
    except (UnicodeDecodeError, json.JSONDecodeError):
        raise VerificationError("GitHub returned invalid JSON") from None
    require(isinstance(data, dict), "GitHub metadata must be an object")
    return data


def resolve_tag(tag: str, get_json: Callable[[str], dict] = fetch_json) -> tuple[str, str]:
    """Require an annotated tag and resolve only objects from the fixed repository."""
    require(isinstance(tag, str) and tag.startswith("v"), "Release tag must start with v")
    parse_version(tag[1:])
    ref = get_json(f"{API}/git/ref/tags/{tag}")
    require(ref.get("ref") == f"refs/tags/{tag}", "Tag reference identity mismatch")
    obj = ref.get("object", {})
    require(obj.get("type") == "tag" and SHA1.fullmatch(str(obj.get("sha", ""))) is not None, "Expected an annotated release tag")
    tag_object = obj["sha"]
    seen: set[str] = set()
    for depth in range(4):
        require(obj["sha"] not in seen, "Tag object cycle")
        seen.add(obj["sha"])
        value = get_json(f"{API}/git/tags/{obj['sha']}")
        require(value.get("sha") == obj["sha"], "Tag object identity mismatch")
        if depth == 0:
            require(value.get("tag") == tag, "Annotated tag name mismatch")
        obj = value.get("object", {})
        require(SHA1.fullmatch(str(obj.get("sha", ""))) is not None, "Invalid tag target SHA")
        if obj.get("type") == "commit":
            return tag_object, obj["sha"]
        require(obj.get("type") == "tag", "Release tag must resolve to a commit")
    raise VerificationError("Release tag has too many nested objects")


def release_metadata(release: dict, tag_object: str, commit: str) -> dict | None:
    require(isinstance(release, dict), "Release must be an object")
    if release.get("draft") is True or release.get("prerelease") is True:
        return None
    require(release.get("draft") is False and release.get("prerelease") is False, "Release stability flags missing")
    tag = release.get("tag_name", "")
    require(isinstance(tag, str) and tag.startswith("v"), "Invalid release tag")
    version = tag[1:]
    parse_version(version)
    require(isinstance(tag_object, str) and isinstance(commit, str) and SHA1.fullmatch(tag_object) is not None
            and SHA1.fullmatch(commit) is not None, "Invalid tag or commit SHA")
    require(type(release.get("id")) is int and release["id"] > 0, "Invalid release ID")
    require(release.get("html_url") == f"{RELEASES}/tag/{tag}", "Release URL identity mismatch")
    require(isinstance(release.get("published_at"), str) and re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", release["published_at"]) is not None, "Invalid publication timestamp")
    expected = set(package_names(version)) | {"SHA256SUMS.txt"}
    assets = release.get("assets")
    require(isinstance(assets, list) and len(assets) == len(expected), "Release must contain exactly ten packages and SHA256SUMS.txt")
    normalized = []
    seen: set[str] = set()
    for asset in assets:
        require(isinstance(asset, dict), "Invalid asset metadata")
        name = asset.get("name")
        require(isinstance(name, str) and name in expected and name not in seen, "Unexpected or duplicate release asset")
        seen.add(name)
        require(asset.get("state") == "uploaded", f"Asset is not uploaded: {name}")
        size = asset.get("size")
        limit = MAX_MANIFEST_BYTES if name == "SHA256SUMS.txt" else MAX_ASSET_BYTES
        require(type(size) is int and 0 < size <= limit, f"Invalid asset size: {name}")
        digest = asset.get("digest", "")
        require(isinstance(digest, str) and digest.startswith("sha256:") and SHA256.fullmatch(digest[7:]) is not None, f"Missing SHA256 digest: {name}")
        require(type(asset.get("id")) is int and asset["id"] > 0, f"Invalid asset ID: {name}")
        url = f"{RELEASES}/download/{tag}/{name}"
        require(asset.get("browser_download_url") == url, f"Asset URL identity mismatch: {name}")
        normalized.append({"name": name, "id": asset["id"], "size": size, "sha256": digest[7:], "url": url})
    require(seen == expected, "Missing release asset")
    return {"schemaVersion": 1, "repository": REPOSITORY, "version": version, "tag": tag,
            "tagObject": tag_object, "commit": commit, "releaseId": release["id"],
            "releaseUrl": release["html_url"], "publishedAt": release["published_at"],
            "assets": sorted(normalized, key=lambda item: item["name"])}


def validate_saved(metadata: dict) -> dict:
    require(isinstance(metadata, dict) and type(metadata.get("schemaVersion")) is int and metadata.get("schemaVersion") == 1
            and metadata.get("repository") == REPOSITORY, "Unsupported local release metadata")
    require(set(metadata) == {"schemaVersion", "repository", "version", "tag", "tagObject", "commit", "releaseId", "releaseUrl", "publishedAt", "assets"}, "Unexpected local metadata fields")
    release = {"draft": False, "prerelease": False, "tag_name": metadata.get("tag"),
               "id": metadata.get("releaseId"), "html_url": metadata.get("releaseUrl"),
               "published_at": metadata.get("publishedAt"), "assets": []}
    require(isinstance(metadata.get("assets"), list), "Local assets must be a list")
    for asset in metadata["assets"]:
        require(isinstance(asset, dict) and set(asset) == {"name", "id", "size", "sha256", "url"}, "Unexpected local asset fields")
        release["assets"].append({"name": asset["name"], "id": asset["id"], "size": asset["size"],
                                  "digest": f"sha256:{asset['sha256']}", "state": "uploaded",
                                  "browser_download_url": asset["url"]})
    normalized = release_metadata(release, metadata.get("tagObject", ""), metadata.get("commit", ""))
    require(normalized == metadata, "Local release metadata is not canonical")
    return metadata


def check_transition(previous: dict | None, candidate: dict) -> bool:
    """Return true for a newer release; never silently repin an existing version."""
    if previous is None:
        return True
    validate_saved(previous)
    old, new = parse_version(previous["version"]), parse_version(candidate["version"])
    require(new >= old, "Refusing to downgrade the tap")
    if new == old:
        require(candidate == previous, "Existing release identity, sizes or digests changed; manual review required")
        return False
    return True


def parse_manifest(content: bytes, metadata: dict) -> dict[str, str]:
    require(len(content) <= MAX_MANIFEST_BYTES, "Checksum manifest is too large")
    try:
        lines = content.decode("ascii").splitlines()
    except UnicodeDecodeError:
        raise VerificationError("Checksum manifest is not ASCII") from None
    checksums: dict[str, str] = {}
    for line in lines:
        match = re.fullmatch(r"([0-9a-f]{64})  ([A-Za-z0-9.-]+)", line)
        require(match is not None, "Malformed checksum manifest line")
        digest, name = match.groups()
        require(name not in checksums, "Duplicate checksum manifest name")
        checksums[name] = digest
    expected = {asset["name"]: asset["sha256"] for asset in metadata["assets"] if asset["name"] != "SHA256SUMS.txt"}
    require(checksums == expected, "Manifest names or checksums differ from GitHub asset digests")
    return checksums


def verify_downloads(metadata: dict, download: Callable = fetch) -> None:
    for asset in metadata["assets"]:
        digest = hashlib.sha256()
        count = 0

        def consume(chunk: bytes) -> None:
            nonlocal count
            count += len(chunk)
            require(count <= asset["size"], f"Downloaded asset is larger than GitHub metadata: {asset['name']}")
            digest.update(chunk)

        if asset["name"] == "SHA256SUMS.txt":
            body = download(asset["url"], asset["size"], asset["name"])
            consume(body)
            parse_manifest(body, metadata)
        else:
            download(asset["url"], asset["size"], asset["name"], consume)
        require(count == asset["size"], f"Downloaded asset size differs from GitHub metadata: {asset['name']}")
        require(digest.hexdigest() == asset["sha256"], f"Downloaded asset digest differs from GitHub metadata: {asset['name']}")


def render_desktop(source: str, metadata: dict) -> str:
    require('url "https://github.com/rosseca/kilo-proxy.git",' in source, "Desktop formula must build from the fixed Kilo Proxy repository")
    require(re.search(r'^  version[ \t]', source, flags=re.MULTILINE) is None,
            "Desktop formula must infer its version from the release tag")
    fields = [
        (r'^([ \t]*tag:[ \t]+)"[^"\n]+"(,?)$', metadata["tag"]),
        (r'^([ \t]*revision:[ \t]+)"[^"\n]+"(,?)$', metadata["commit"]),
    ]
    for pattern, value in fields:
        def replace(match: re.Match) -> str:
            suffix = match.group(2) if match.lastindex == 2 else ""
            return f'{match.group(1)}"{value}"{suffix}'
        source, count = re.subn(pattern, replace, source, flags=re.MULTILINE)
        require(count == 1, "Desktop formula tag/revision contract changed")
    return source


def render_files(root: Path, metadata: dict) -> dict[str, bytes]:
    validate_saved(metadata)
    version = metadata["version"]
    hashes = {asset["name"]: asset["sha256"] for asset in metadata["assets"]}
    result: dict[str, bytes] = {}
    for filename, output, prefix in [
        ("kilo-proxy.rb.tmpl", "Casks/kilo-proxy.rb", "kilo-proxy"),
        ("kilo-proxy-headless.rb.tmpl", "Formula/kilo-proxy-headless.rb", "kilo-proxy-headless"),
    ]:
        values = {"VERSION": version}
        for system in ("darwin", "linux"):
            for arch in ("amd64", "arm64"):
                extension = "zip" if prefix == "kilo-proxy" and system == "darwin" else "tar.gz"
                name = f"{prefix}-{version}-{system}-{arch}.{extension}"
                values[f"{system.upper()}_{arch.upper()}_SHA256"] = hashes[name]
        template = string.Template((root / "templates" / filename).read_text())
        result[output] = template.substitute(values).encode()
    result["Formula/kilo-proxy-desktop.rb"] = render_desktop((root / "Formula/kilo-proxy-desktop.rb").read_text(), metadata).encode()
    result[METADATA] = (json.dumps(metadata, indent=2, sort_keys=True) + "\n").encode()
    return result


def check_files(root: Path, metadata: dict) -> None:
    for filename, expected in render_files(root, metadata).items():
        require((root / filename).is_file() and (root / filename).read_bytes() == expected, f"Generated file is out of date: {filename}")


def write_files(root: Path, files: dict[str, bytes]) -> None:
    """Stage every validated output before replacing any destination."""
    staged: list[tuple[Path, Path]] = []
    try:
        for filename, content in files.items():
            destination = root / filename
            destination.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(dir=destination.parent, prefix=f".{destination.name}.", delete=False) as stream:
                temporary = Path(stream.name)
                staged.append((temporary, destination))
                stream.write(content)
                stream.flush()
                os.fsync(stream.fileno())
            temporary.chmod(0o644)
        for temporary, destination in staged:
            os.replace(temporary, destination)
    finally:
        for temporary, _ in staged:
            temporary.unlink(missing_ok=True)


def update(root: Path, get_json: Callable = fetch_json, download: Callable = fetch) -> bool:
    latest = get_json(f"{API}/releases/latest")
    if latest.get("draft") is True or latest.get("prerelease") is True:
        print("Skipping draft or prerelease")
        return False
    tag_object, commit = resolve_tag(latest.get("tag_name", ""), get_json)
    candidate = release_metadata(latest, tag_object, commit)
    require(candidate is not None, "Stable release is required")
    previous = json.loads((root / METADATA).read_text()) if (root / METADATA).exists() else None
    if not check_transition(previous, candidate):
        check_files(root, previous)
        print(f"Kilo Proxy {candidate['version']} is already verified and current")
        return False
    files = render_files(root, candidate)
    verify_downloads(candidate, download)
    # Tag mutation during downloads must not publish a candidate tied to old code.
    require(resolve_tag(candidate["tag"], get_json) == (tag_object, commit), "Release tag changed while downloading")
    final = release_metadata(get_json(f"{API}/releases/{candidate['releaseId']}"), tag_object, commit)
    require(final == candidate, "Release assets changed while downloading")
    write_files(root, files)
    print(f"Updated tap to verified Kilo Proxy {candidate['version']}")
    return True


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check committed generated files offline without modifying them")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent, help="Tap checkout root")
    args = parser.parse_args(argv)
    try:
        if args.check:
            metadata = validate_saved(json.loads((args.root / METADATA).read_text()))
            check_files(args.root, metadata)
            print(f"Generated files match Kilo Proxy {metadata['version']}")
        else:
            update(args.root)
    except (VerificationError, OSError, UnicodeDecodeError, json.JSONDecodeError, KeyError, TypeError) as exc:
        print(f"Kilo Proxy update failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
