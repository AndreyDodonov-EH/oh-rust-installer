#!/bin/bash
# install.sh

set -e

# Detect platform
detect_platform() {
    local os arch

    # Detect OS
    case "$(uname -s)" in
        Linux*)
            if ldd /bin/ls 2>&1 | grep -q musl; then
                os="unknown-linux-musl"
            else
                os="unknown-linux-gnu"
            fi
            ;;
        Darwin*)
            os="apple-darwin"
            ;;
        MINGW*|CYGWIN*|MSYS*)
            os="pc-windows-msvc"
            ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="aarch64"
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac

    echo "${arch}-${os}"
}

PLATFORM=$(detect_platform)

# For latest version
DOWNLOAD_URL="https://github.com/AndreyDodonov-EH/oh-rust/releases/latest/download/oh-rust-latest-${PLATFORM}.tar.gz"

# For exact version. ToDo: provide parameter to script
# VERSION="1.88.0-oh-0.0.1"
# DOWNLOAD_URL="https://github.com/AndreyDodonov-EH/oh-rust/releases/download/${VERSION}/oh-rust-latest-${PLATFORM}.tar.gz"

echo "Detected platform: $PLATFORM"
echo "Downloading Oh-Rust..."

# Download and install
curl -L "$DOWNLOAD_URL" -o oh-rust.tar.gz || {
    echo "Failed to download Oh-Rust for $PLATFORM"
    echo "Please check if this platform is supported"
    exit 1
}

mkdir -p ~/.oh-rust
tar -xzf oh-rust.tar.gz -C ~/.oh-rust
rm oh-rust.tar.gz

# Set up rustup if available
if command -v rustup &>/dev/null; then
    rustup toolchain link oh-rust ~/.oh-rust
    rustup default oh-rust
    echo "Oh-Rust installed and set as default via rustup!"
else
    echo "Oh-Rust installed to ~/.oh-rust"
    echo "Add ~/.oh-rust/bin to your PATH, or install rustup for easier management"
fi
