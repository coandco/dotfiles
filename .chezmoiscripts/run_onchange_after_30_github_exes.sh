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
  armv7*)
    cputype=armv7
    ;;
esac

# Load up homebrew paths if necessary to make sure wget is available
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! [ -f ~/.local/bin/cdebug ]; then
  cdebug_url="https://github.com/iximiuz/cdebug/releases/download/v0.0.19/cdebug_${ostype}_${cputype}.tar.gz"
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
  doggo_url="https://github.com/mr-karan/doggo/releases/download/v1.1.14/doggo_1.1.14_${doggo_os}_${doggo_cpu}.tar.gz"
  if is_valid_url "$doggo_url"; then
    wget "$doggo_url" -O doggo.tar.gz
    if [ -f doggo.tar.gz ]; then
      doggo_loc=$(tar -tf doggo.tar.gz | grep '/doggo$' | head -n 1)
      tar xzf doggo.tar.gz -C ~/.local/bin --strip-components=1 "$doggo_loc"
      rm -rf doggo.tar.gz
    fi
  else
    echo "No release of doggo found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/fzf ]; then
  fzf_url="https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-${ostype}_${cputype}.tar.gz"
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
  atuin_url="https://github.com/atuinsh/atuin/releases/download/v18.12.1/atuin-${atuin_cpu}-${atuin_os}.tar.gz"
  if is_valid_url "$atuin_url"; then
    wget "$atuin_url" -O atuin.tar.gz
    if [ -f atuin.tar.gz ]; then
      atuin_loc=$(tar -tf atuin.tar.gz | grep '/atuin$' | head -n 1)
      tar xzf atuin.tar.gz --strip-components=1 -C ~/.local/bin/ "$atuin_loc"
      rm -rf atuin.tar.gz
    fi
  else
    echo "No release of atuin found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/wormhole ]; then
  if [ "$ostype" == "darwin" ]; then
    wormhole_url="https://github.com/magic-wormhole/magic-wormhole.rs/releases/download/0.7.6/magic-wormhole-cli-aarch64-apple-darwin.tgz"
  elif [ "$ostype" == "linux" ]; then
    wormhole_url="https://github.com/magic-wormhole/magic-wormhole.rs/releases/download/0.7.6/magic-wormhole-cli-x86_64-unknown-linux-gnu.tgz"
  else
    wormhole_url="invalid"
  fi

  if is_valid_url "$wormhole_url"; then
    wget "$wormhole_url" -O wormhole-rs.tar.gz
    if [ -f wormhole-rs.tar.gz ]; then
      tar xzf wormhole-rs.tar.gz
      mv wormhole-rs ~/.local/bin/wormhole
      rm wormhole-rs.tar.gz
    fi
  else
    echo "No release of wormhole-rs found for $ostype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/fzf ]; then
  fzf_url="https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-${ostype}_${cputype}.tar.gz"
  if is_valid_url "$fzf_url"; then
    wget "$fzf_url" -O fzf.tar.gz
    tar xzf fzf.tar.gz -C ~/.local/bin/
    rm fzf.tar.gz
  else
    echo "No release of fzf found for $ostype/$cputype, skipping"
  fi
fi

if ! [ -f ~/.local/bin/pandoc ]; then
  pandoc_ver="3.8.3"
  pandoc_baseurl="https://github.com/jgm/pandoc/releases/download/${pandoc_ver}/pandoc-${pandoc_ver}-"
  pandoc_slug="linux-amd64.tar.gz"
  if [ "$ostype" == "darwin" ]; then
    if [ "$cputype" == "arm64" ]; then
      pandoc_slug="arm64-macOS.zip"
    else
      pandoc_slug="x86_64-macOS.zip"
    fi
  fi
  pandoc_url="${pandoc_baseurl}${pandoc_slug}"
  if is_valid_url "$pandoc_url"; then
    wget "$pandoc_url" -O "$pandoc_slug"
    case "$ostype" in
      linux)
        pandoc_loc=$(tar -tf "$pandoc_slug" | grep '/pandoc$' | head -n 1)
        tar xzf "$pandoc_slug" -C ~/.local/bin --strip-components=2 "$pandoc_loc"
        rm "$pandoc_slug"
        ;;
      darwin)
        unzip -j "$pandoc_slug" '**/pandoc'
        mv pandoc ~/.local/bin/
        rm "$pandoc_slug"
        ;;
    esac
  fi
fi

if ! [ -f ~/.local/bin/bsdtar ]; then
  bsdtar_url="https://github.com/aspect-build/bsdtar-prebuilt/releases/download/v3.8.1-fix.1/tar_${ostype}_${cputype}"
  if is_valid_url "$bsdtar_url"; then
    wget "$bsdtar_url" -O ~/.local/bin/bsdtar
    chmod a+x ~/.local/bin/bsdtar
  fi
fi

if ! [ -f ~/.local/bin/lesspipe.sh ]; then
  lesspipe_url="https://github.com/wofr06/lesspipe/archive/refs/tags/v2.22.zip"
  wget "$lesspipe_url" -O lesspipe.zip
  unzip -j -o lesspipe.zip '*/lesspipe.sh' '*/code2color' '*/lesscomplete' '*/vimcolor' -d ~/.local/bin
  rm lesspipe.zip
fi

if ! [ -f ~/.local/bin/rg ]; then
  rg_ver="15.1.0"
  [[ $cputype = "amd64" ]] && rg_cputype="x86_64" || rg_cputype="aarch64"
  [[ $ostype = "linux" ]] && rg_ostype="unknown-linux-musl" || rg_ostype="apple-darwin"
  rg_url="https://github.com/BurntSushi/ripgrep/releases/download/${rg_ver}/ripgrep-${rg_ver}-${rg_cputype}-${rg_ostype}.tar.gz"
  if is_valid_url "$rg_url"; then
    wget "$rg_url" -O ripgrep.tar.gz
    rg_loc=$(tar -tf ripgrep.tar.gz | grep '/rg$' | head -n 1)
    tar xzf ripgrep.tar.gz -C ~/.local/bin --strip-components=1 "$rg_loc"
    rm ripgrep.tar.gz
  fi
fi

if ! [ -f ~/.local/bin/psc ]; then
  psc_ver="0.3.2"
  psc_url="https://github.com/loresuso/psc/releases/download/v${psc_ver}/psc_${psc_ver}_${ostype}_${cputype}.tar.gz"
  if is_valid_url "$psc_url"; then
    wget "$psc_url" -O psc.tar.gz
    tar xzf psc.tar.gz -C ~/.local/bin 'psc'
    rm psc.tar.gz
  fi
fi

if ! [ -f ~/.local/bin/soar ]; then
  soar_ver="0.11.0"
  [[ $cputype = "amd64" ]] && soar_cputype="x86_64" || soar_cputype="aarch64"
  soar_url="https://github.com/pkgforge/soar/releases/download/v${soar_ver}/soar-${soar_cputype}-${ostype}"
  if is_valid_url "$soar_url"; then
    wget "$soar_url" -O ~/.local/bin/soar
    chmod a+x ~/.local/bin/soar
  fi
fi

if ! [ -f ~/.local/bin/whosthere ]; then
  wt_ver="0.6.1"
  wt_url="https://github.com/ramonvermeulen/whosthere/releases/download/v${wt_ver}/whosthere_${wt_ver}_${ostype}_${cputype}.tar.gz"
  if is_valid_url "$wt_url"; then
    wget "$wt_url" -O wt.tar.gz
    tar xzf wt.tar.gz -C ~/.local/bin 'whosthere'
    rm wt.tar.gz
  fi
fi
