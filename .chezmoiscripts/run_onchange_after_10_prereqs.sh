#!/bin/bash

is_brew_package_installed() {
  local pkg="$1"
  brew ls --versions "$pkg" &> /dev/null
  return $?
}

is_apt_package_installed() {
  local pkg="$1"
  [ $(dpkg-query -W -f='${Status}' "$pkg") == "install ok installed" ]
  return $?
}

needed_packages() {
  local pkg_list="$1"
  local absent_pkgs=()
  [[ "$OSTYPE" == "darwin"* ]] && pkgmgr="brew" || pkgmgr="apt"
  for pkg in $pkg_list; do
    if ! "is_$pkgmgr_package_installed" "$pkg"; then
      absent_pkgs+=("$pkg")
    fi
  done
  echo "${absent_pkgs[@]}"
}


# On mac, install base packages with homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Install homebrew if necessary
  if ! hash brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew_pkgs=(bash nano wget less poppler squashfs p7zip pigz)
  absent_pkgs=$(needed_packages "$brew_pkgs")
  if [ -n "$absent_pkgs" ]; then
    echo "Missing brew packages.  To install, run '/opt/homebrew/bin/brew install $absent_pkgs'"
  fi

# On Debian-based systems, install base packages with apt-get
elif [[ "$OSTYPE" == "linux-gnu"* ]] && hash apt-get &> /dev/null; then
  echo "Installing prereq packages"
  apt_pkgs=(nano wget curl less catdoc poppler-utils squashfs-tools p7zip pigz)
  # "arm" (i.e. armv7 i.e. not arm64) doesn't have python wheels for a couple of packages, so get prereqs
  if [[ "$(uname -m)" == "arm"* ]]; then
    apt_pkgs+=(libffi-dev libsodium-dev)
  fi
  absent_pkgs=$(needed_pkgs "$apt_pkgs")
  if [ -n "$absent_pkgs" ]; then
    echo "Missing apt packages.  To install, run 'sudo apt-get install $absent_pkgs'"
  fi
fi
