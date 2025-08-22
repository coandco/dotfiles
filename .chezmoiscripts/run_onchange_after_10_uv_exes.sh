#!/bin/bash

mkdir -p ~/.local/bin

if ! [ -x "~/.local/bin/uv" ]; then
  UV_NO_MODIFY_PATH=1 UV_INSTALL_DIR="~/.local/bin" ~/.local/bin/uv-installer
fi

if ! [ -x "~/.local/bin/xonsh" ]; then
  uv tool install xonsh[full] --with pip
fi

if ! [ -x "~/.local/bin/black" ]; then
  uv tool install black
fi

if ! [ -x "~/.local/bin/isort" ]; then
  uv tool install isort
fi

if ! [ -x "~/.local/bin/ipython" ]; then
  uv tool install ipython --with pip
fi

if ! [ -x "~/.local/bin/yt-dlp" ]; then
  uv tool install yt-dlp[default]
fi

if ! [ -x "~/.local/bin/wormhole" ]; then
  uv tool install magic-wormhole
fi
