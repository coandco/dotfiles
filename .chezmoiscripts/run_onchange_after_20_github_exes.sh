#!/bin/bash

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

if ! [ -f ~/.local/bin/cdebug ]; then
  wget "https://github.com/iximiuz/cdebug/releases/download/v0.0.18/cdebug_${ostype}_${cputype}.tar.gz" -O cdebug.tar.gz
  if [ -f cdebug.tar.gz ]; then
    tar xvf cdebug.tar.gz -C ~/.local/bin cdebug
    rm cdebug.tar.gz
  fi
fi

if ! [ -x ~/.local/bin/doggo ]; then
  # uppercase the first letter
  doggo_os="${ostype^}"
  # doggo uses arm64/x86_64
  doggo_cpu="$cputype"
  if [ "$doggo_cpu" = "amd64" ]; then
    doggo_cpu="x86_64"
  fi
  wget "https://github.com/mr-karan/doggo/releases/download/v1.0.5/doggo_1.0.5_${doggo_os}_${doggo_cpu}.tar.gz" -O doggo.tar.gz
  if [ -f doggo.tar.gz ]; then
    mkdir tmp_doggo
    tar xzf doggo.tar.gz --strip-components=1 -C tmp_doggo
    mv tmp_doggo/doggo ~/.local/bin
    rm -rf doggo.tar.gz tmp_doggo
  fi
fi

if ! [ -f ~/.local/bin/fzf ]; then
  wget "https://github.com/junegunn/fzf/releases/download/v0.65.1/fzf-0.65.1-${ostype}_${cputype}.tar.gz" -O fzf.tar.gz
  if [ -f fzf.tar.gz ]; then
    tar xzf fzf.tar.gz -C ~/.local/bin fzf
    rm fzf.tar.gz
  fi
fi

if ! [ -f ~/.local/bin/jq ]; then
  jq_os="$ostype"
  if [ "$jq_os" = "darwin" ]; then
    jq_os="macos"
  fi
  wget "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-${jq_os}-${cputype}" -O ~/.local/bin/jq
  if [ -f ~/.local/bin/jq ]; then
    chmod a+x ~/.local/bin/jq
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
  wget "https://github.com/atuinsh/atuin/releases/download/v18.8.0/atuin-${atuin_cpu}-${atuin_os}.tar.gz" -O atuin.tar.gz
  if [ -f atuin.tar.gz ]; then
    tar xzf atuin.tar.gz --strip-components=1 -C tmp_atuin
    mv tmp_atuin/atuin ~/.local/bin/
    rm -rf atuin.tar.gz tmp_atuin
  fi
fi
