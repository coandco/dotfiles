#!/bin/bash

# On mac, install base packages with homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Install homebrew if necessary
  if ! hash brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Install base packages
  /opt/homebrew/bin/brew install bash nano wget less poppler squashfs p7zip pigz

# On Debian-based systems, install base packages with apt-get
elif [[ "$OSTYPE" == "linux-gnu"* ]] && hash apt-get; then
  sudo apt-get install --yes bash nano wget curl less catdoc poppler-utils squashfs-tools p7zip pigz
  # "arm" (i.e. armv7 i.e. not arm64) doesn't have python wheels for a couple of packages, so get prereqs
  if [[ "$(uname -m)" == "arm"* ]]; then
    sudo apt-get install libffi-dev libsodium-dev
  fi
fi
