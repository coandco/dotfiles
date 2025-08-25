#!/bin/bash

function is_valid_url() {
  url="$1"
  retcode="$(curl --location --head --silent --write-out '%{http_code}' --output /dev/null "$url")"
  if [ "$retcode" = "200" ]; then
    return 0
  else
    return 1
  fi
}

mkdir -p ~/.local/bin

ostype="$(uname -s | tr '[:upper:]' '[:lower:]')"
cputype="$(uname -m)"

# Normalize architecture
case "$cputype" in
  aarch64 | arm64)
    cputype=arm64
    ;;
  x86_64 | x86-64 | x64 | amd64)
    cputype=amd64
    ;;
esac

# Load up homebrew paths if necessary to make sure wget is available
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! [ -f ~/.local/bin/cdebug ]; then
  cdebug_url="https://github.com/iximiuz/cdebug/releases/download/v0.0.18/cdebug_${ostype}_${cputype}.tar.gz"
  if is_valid_url "$cdebug_url"; then
    wget "$cdebug_url" -O cdebug.tar.gz
    if [ -f cdebug.tar.gz ]; then
      tar xvf cdebug.tar.gz -C ~/.local/bin cdebug
      rm cdebug.tar.gz
    fi
  else
    echo "No release of cdebug found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -x ~/.local/bin/doggo ]; then
  # uppercase the first letter
  doggo_os="$(echo $ostype | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')"
  # doggo uses arm64/x86_64
  doggo_cpu="$cputype"
  if [ "$doggo_cpu" = "amd64" ]; then
    doggo_cpu="x86_64"
  fi
  doggo_url="https://github.com/mr-karan/doggo/releases/download/v1.0.5/doggo_1.0.5_${doggo_os}_${doggo_cpu}.tar.gz"
  if is_valid_url "$doggo_url"; then
    wget "$doggo_url" -O doggo.tar.gz
    if [ -f doggo.tar.gz ]; then
      mkdir tmp_doggo
      tar xzf doggo.tar.gz --strip-components=1 -C tmp_doggo
      mv tmp_doggo/doggo ~/.local/bin
      rm -rf doggo.tar.gz tmp_doggo
    fi
  else
    echo "No release of doggo found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/fzf ]; then
  fzf_url="https://github.com/junegunn/fzf/releases/download/v0.65.1/fzf-0.65.1-${ostype}_${cputype}.tar.gz"
  if is_valid_url "$fzf_url"; then
    wget "$fzf_url" -O fzf.tar.gz
    if [ -f fzf.tar.gz ]; then
      tar xzf fzf.tar.gz -C ~/.local/bin fzf
      rm fzf.tar.gz
    fi
  else
    echo "No release of fzf found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/jq ]; then
  jq_os="$ostype"
  if [ "$jq_os" = "darwin" ]; then
    jq_os="macos"
  fi
  jq_url="https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-${jq_os}-${cputype}"
  if is_valid_url "$jq_url"; then
    wget "$jq_url" -O ~/.local/bin/jq
    if [ -f ~/.local/bin/jq ]; then
      chmod a+x ~/.local/bin/jq
    fi
  else
    echo "No release of jq found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/atuin ]; then
  atuin_os="$ostype"
  case "$atuin_os" in
    linux)
      atuin_os="unknown-linux-gnu"
      ;;
    darwin)
      atuin_os="apple-darwin"
      ;;
  esac
  atuin_cpu="$cputype"
  case "$atuin_cpu" in
    amd64)
      atuin_cpu="x86_64"
      ;;
    arm64)
      atuin_cpu="aarch64"
      ;;
  esac
  atuin_url="https://github.com/atuinsh/atuin/releases/download/v18.8.0/atuin-${atuin_cpu}-${atuin_os}.tar.gz"
  if is_valid_url "$atuin_url"; then
    wget "$atuin_url" -O atuin.tar.gz
    if [ -f atuin.tar.gz ]; then
      mkdir -p tmp_atuin
      tar xzf atuin.tar.gz --strip-components=1 -C tmp_atuin
      mv tmp_atuin/atuin ~/.local/bin/
      rm -rf atuin.tar.gz tmp_atuin
    fi
  else
    echo "No release of atuin found for $ostype/$cputype, skipping"
  fi
fi
