#!/bin/bash
# install.sh

set -e

# Ask the important question
echo -n "Ready to get rustrated? [Y/n] "
read -r response

# Default to yes if empty or starts with y/Y
if [[ -z "$response" || "$response" =~ ^[Yy] ]]; then
    echo "Brave choice. Let's do this."
    echo
else
    echo "Okay, then."
    exit 0
fi

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
            echo "Even I'm not cruel enough to support that."
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
            echo "What are you even running this on?"
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
echo "(This is your last chance to reconsider your life choices)"
echo

# Download and install
curl -L "$DOWNLOAD_URL" -o oh-rust.tar.gz || {
    echo "Failed to download Oh-Rust for $PLATFORM"
    echo "Even the internet is trying to save you from yourself."
    exit 1
}

echo
echo "Installing to ~/.oh-rust..."
echo "(No turning back now)"

mkdir -p ~/.oh-rust
tar -xzf oh-rust.tar.gz -C ~/.oh-rust
rm oh-rust.tar.gz

# Set up rustup if available
if command -v rustup &>/dev/null; then
    rustup toolchain link oh-rust ~/.oh-rust
    rustup default oh-rust
    echo
    echo "✓ Oh-Rust installed and set as default via rustup!"
    echo "  Your regular Rust compiler has been dethroned."
else
    echo
    echo "✓ Oh-Rust installed to ~/.oh-rust"
    echo "  Add ~/.oh-rust/bin to your PATH, or install rustup for easier management"
    echo "  (Yes, you have to do this yourself. What did you expect?)"
fi

echo
echo "Installation complete. May the compiler have mercy on your code."
