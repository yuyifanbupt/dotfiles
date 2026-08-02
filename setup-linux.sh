#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '\n\033[1;32m==> %s\033[0m\n' "$*"
}

die() {
  printf '\nError: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  elif command_exists sudo; then
    sudo "$@"
  else
    die "Root privileges are required to run: $* (sudo is not installed)"
  fi
}

install_system_packages() {
  local packages=()

  if command_exists apt-get; then
    packages=(zsh git curl ca-certificates autojump build-essential procps file)
    log "Installing system packages with apt"
    run_as_root apt-get update
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
  elif command_exists dnf; then
    packages=(zsh git curl ca-certificates autojump procps-ng file gcc gcc-c++ make)
    log "Installing system packages with dnf"
    run_as_root dnf install -y "${packages[@]}"
  elif command_exists yum; then
    packages=(zsh git curl ca-certificates autojump procps-ng file gcc gcc-c++ make)
    log "Installing system packages with yum"
    run_as_root yum install -y "${packages[@]}"
  elif command_exists pacman; then
    packages=(zsh git curl ca-certificates autojump base-devel procps-ng file)
    log "Installing system packages with pacman"
    run_as_root pacman -Sy --needed --noconfirm "${packages[@]}"
  elif command_exists zypper; then
    packages=(zsh git curl ca-certificates autojump procps file gcc gcc-c++ make)
    log "Installing system packages with zypper"
    run_as_root zypper --non-interactive install "${packages[@]}"
  else
    die "Unsupported package manager; supported managers are apt, dnf, yum, pacman, and zypper"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
    log "Oh My Zsh is already installed; skipping"
    return
  fi

  [[ ! -e "$HOME/.oh-my-zsh" ]] || die "$HOME/.oh-my-zsh exists but is not a Git repository; inspect or move it first"
  log "Installing Oh My Zsh"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
}

install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local zsh_autosuggestions_dir="$custom_dir/plugins/zsh-autosuggestions"
  local zsh_syntax_highlighting_dir="$custom_dir/plugins/zsh-syntax-highlighting"

  mkdir -p -- "$custom_dir/plugins"
  if [[ -d "$zsh_autosuggestions_dir/.git" ]]; then
    log "zsh-autosuggestions is already installed; skipping"
  else
    [[ ! -e "$zsh_autosuggestions_dir" ]] || die "$zsh_autosuggestions_dir exists but is not a Git repository; inspect or move it first"
    log "Installing zsh-autosuggestions"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_autosuggestions_dir"
  fi

  if [[ -d "$zsh_syntax_highlighting_dir/.git" ]]; then
    log "zsh-syntax-highlighting is already installed; skipping"
  else
    [[ ! -e "$zsh_syntax_highlighting_dir" ]] || die "$zsh_syntax_highlighting_dir exists but is not a Git repository; inspect or move it first"
    log "Installing zsh-syntax-highlighting"
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_syntax_highlighting_dir"
  fi
}

set_default_shell() {
  local zsh_path current_shell
  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || true)"
  if [[ "$current_shell" != "$zsh_path" ]]; then
    log "Setting the default shell to $zsh_path"
    if ! chsh -s "$zsh_path"; then
      printf 'Warning: Failed to change the default shell automatically. Run this manually: chsh -s %q\n' "$zsh_path" >&2
    fi
  fi
}

install_homebrew() {
  local brew_bin=""

  if command_exists brew; then
    brew_bin="$(command -v brew)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    brew_bin=/home/linuxbrew/.linuxbrew/bin/brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
  fi

  if [[ -n "$brew_bin" ]]; then
    log "Homebrew is already installed at $($brew_bin --prefix)"
    return
  fi

  [[ ${EUID:-$(id -u)} -ne 0 ]] || die "Homebrew cannot be installed as root; run this script as a regular user"
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  command_exists brew || die "Homebrew installation completed, but the brew command could not be found"
}

install_brew_packages() {
  local brew_bin=""
  local packages=(
    uv
    nvim
    bat
    lazygit
    codex
    dust
    duf
    jq
    tlrc
    cheat
    fzf
    yazi
    ffmpeg-full
    sevenzip
    poppler
    fd
    ripgrep
    zoxide
    resvg
    imagemagick-full
    font-symbols-only-nerd-font
    tree-sitter-cli
    hf
    git-delta
    tmux
    node
  )

  log "Installing command-line tools with Homebrew"
  brew install "${packages[@]}"
}

main() {
  [[ "$(uname -s)" == Linux ]] || die "This script currently supports Linux only"
  [[ ${EUID:-$(id -u)} -ne 0 ]] || die "Run this script as a regular user; it invokes sudo when system privileges are required"

  install_system_packages
  command_exists zsh || die "Failed to install zsh"
  install_oh_my_zsh
  install_zsh_plugins
  set_default_shell
  install_homebrew
  install_brew_packages
  "$script_dir/sync.sh" all

  log "Setup complete"
  printf 'The default zsh environment will take effect at the next login. To start it now, run: exec zsh -l\n'
}

main "$@"
