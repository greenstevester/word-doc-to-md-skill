#!/usr/bin/env bash
set -euo pipefail

# Install docx-to-md binary from GitHub releases.
# Detects OS/arch and downloads the correct pre-built binary.

REPO="greenstevester/word-doc-to-md-skill-go"
BINARY_NAME="docx-to-md"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# Detect platform
detect_platform() {
  local os arch

  case "$(uname -s)" in
    Linux*)  os="linux" ;;
    Darwin*) os="darwin" ;;
    MINGW*|MSYS*|CYGWIN*) os="windows" ;;
    *) echo "ERROR: Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64)  arch="amd64" ;;
    arm64|aarch64)  arch="arm64" ;;
    *) echo "ERROR: Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  echo "${os}_${arch}"
}

# Get latest release tag from GitHub API
get_latest_version() {
  local version
  version=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

  if [ -z "$version" ]; then
    echo "ERROR: Could not determine latest version" >&2
    exit 1
  fi
  echo "$version"
}

main() {
  local platform version version_no_v archive_name url ext

  platform=$(detect_platform)
  version="${1:-$(get_latest_version)}"
  version_no_v="${version#v}"

  echo "Installing ${BINARY_NAME} ${version} for ${platform}..."

  # Determine archive extension
  case "$platform" in
    windows_*) ext="zip" ;;
    *)         ext="tar.gz" ;;
  esac

  archive_name="${BINARY_NAME}_${version_no_v}_${platform}.${ext}"
  url="https://github.com/${REPO}/releases/download/${version}/${archive_name}"

  echo "  Downloading ${archive_name}..."

  local tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  curl -fsSL -o "${tmpdir}/archive" "$url"

  echo "  Extracting..."
  case "$ext" in
    tar.gz)
      tar -xzf "${tmpdir}/archive" -C "$tmpdir"
      ;;
    zip)
      unzip -q "${tmpdir}/archive" -d "$tmpdir"
      ;;
  esac

  # Find and install the binary
  local bin_name="${BINARY_NAME}"
  if [[ "$platform" == windows_* ]]; then
    bin_name="${BINARY_NAME}.exe"
  fi

  if [ -f "${tmpdir}/${bin_name}" ]; then
    mv "${tmpdir}/${bin_name}" "${INSTALL_DIR}/${bin_name}"
    chmod +x "${INSTALL_DIR}/${bin_name}"
  else
    echo "ERROR: ${bin_name} not found in archive" >&2
    exit 1
  fi

  echo "  Installed -> ${INSTALL_DIR}/${bin_name}"
  echo "Done."
}

main "$@"
