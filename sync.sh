#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

sync_tmux() {
  local target="$HOME/.tmux.conf"
  local source="$script_dir/tmux/.tmux.conf"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
  fi

  ln -s -- "$source" "$target"
}

sync_codex() {
  local target_dir="$HOME/.codex"
  local target="$target_dir/config.toml"
  local source="$script_dir/codex/config.toml"

  mkdir -p -- "$target_dir"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
  fi

  ln -s -- "$source" "$target"
}

sync_zsh() {
  local target="$HOME/.zshrc"
  local source="$script_dir/zsh/.zshrc"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
  fi

  ln -s -- "$source" "$target"
}

sync_git() {
  local target="$HOME/.gitconfig"
  local source="$script_dir/git/.gitconfig"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
  fi

  ln -s -- "$source" "$target"
}

sync_lazygit() {
  local target_dir="$HOME/.config/lazygit"
  local target="$target_dir/config.yml"
  local source="$script_dir/lazygit/config.yml"

  mkdir -p -- "$target_dir"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
  fi

  ln -s -- "$source" "$target"
}

sync_nvim() {
  local target_dir="$HOME/.config"
  local target="$target_dir/nvim"
  local source="$script_dir/nvim"

  mkdir -p -- "$target_dir"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf -- "$target"
  fi

  ln -s -- "$source" "$target"
}

print_usage() {
  printf 'Usage: %s <all|tmux|codex|zsh|git|lazygit|nvim>...\n' "$0"
  printf '\n'
  printf 'Options:\n'
  printf '  -h, --help  Show this help message\n'
  printf '\n'
  printf 'Examples:\n'
  printf '  %s nvim\n' "$0"
  printf '  %s nvim tmux\n' "$0"
  printf '  %s all\n' "$0"
}

sync_component() {
  case "$1" in
  tmux) sync_tmux ;;
  codex) sync_codex ;;
  zsh) sync_zsh ;;
  git) sync_git ;;
  lazygit) sync_lazygit ;;
  nvim) sync_nvim ;;
  esac
}

if [[ $# -eq 0 ]]; then
  print_usage >&2
  exit 1
fi

for argument in "$@"; do
  case "$argument" in
  -h | --help)
    print_usage
    exit 0
    ;;
  all | tmux | codex | zsh | git | lazygit | nvim) ;;
  *)
    printf 'Error: unknown argument: %s\n\n' "$argument" >&2
    print_usage >&2
    exit 1
    ;;
  esac
done

if [[ " $* " == *" all "* ]]; then
  components=(tmux codex zsh git lazygit nvim)
else
  components=("$@")
fi

for component in "${components[@]}"; do
  sync_component "$component"
done
