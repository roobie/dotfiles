# Font installer
#
# Usage:
#   just install-iosevka
#   just install-iosevka version=34.3.0
#   just list-iosevka

version := "34.2.1"
variant := "SGr-IosevkaTerm"
font_dir := env("HOME") / ".fonts/iosevka-term"

_zip_name := "PkgTTC-" + variant + "-" + version + ".zip"
_url := "https://github.com/be5invis/Iosevka/releases/download/v" + version + "/" + _zip_name
_download := env("HOME") / "Downloads" / _zip_name

# Install Iosevka Term (downloads if needed)
install-iosevka:
    #!/usr/bin/env bash
    set -euo pipefail
    ZIP="{{_download}}"
    if [ ! -f "$ZIP" ]; then
        echo "Downloading {{_zip_name}}..."
        curl -fSL -o "$ZIP" "{{_url}}"
    else
        echo "Using cached $ZIP"
    fi
    TMP=$(mktemp -d)
    trap "rm -rf $TMP" EXIT
    unzip -q "$ZIP" -d "$TMP"
    mkdir -p "{{font_dir}}"
    cp "$TMP"/*.ttc "{{font_dir}}/"
    fc-cache -f "{{font_dir}}"
    echo "Installed to {{font_dir}}"
    fc-list | grep -i iosevka | head -5 || true

# List installed Iosevka fonts
list-iosevka:
    fc-list | grep -i iosevka | sort

# Remove installed Iosevka fonts
remove-iosevka:
    rm -rf "{{font_dir}}"
    fc-cache -f
    echo "Removed {{font_dir}}"

# ---------------------------------------------------------------------------
# Adobe Source Code Pro
# ---------------------------------------------------------------------------

source_code_pro_dir := env("HOME") / ".fonts/adobe-fonts/source-code-pro"

# Install Source Code Pro from GitHub
install-source-code-pro:
    #!/usr/bin/env bash
    set -euo pipefail
    DIR="{{source_code_pro_dir}}"
    if [ -d "$DIR" ]; then
        echo "Already installed at $DIR — pulling latest..."
        git -C "$DIR" pull
    else
        echo "Cloning Source Code Pro..."
        mkdir -p "$(dirname "$DIR")"
        git clone --depth=1 https://github.com/adobe-fonts/source-code-pro.git "$DIR"
    fi
    fc-cache -f "$DIR"
    echo "Installed to $DIR"
    fc-list | grep -i "source code pro" | head -5 || true

# List installed Source Code Pro fonts
list-source-code-pro:
    fc-list | grep -i "source code pro" | sort

# Remove installed Source Code Pro fonts
remove-source-code-pro:
    rm -rf "{{source_code_pro_dir}}"
    fc-cache -f
    echo "Removed {{source_code_pro_dir}}"
