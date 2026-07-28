#!/usr/bin/env bash

set -Eeuo pipefail

username=""

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

prompt_username() {
  read -r -p "Enter the username to create: " username
  [[ -n "$username" ]] || die "Username cannot be empty"
  [[ "$username" != "root" ]] || die "The root account cannot be used"
  [[ "$username" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || \
    die "Invalid username; use up to 32 lowercase letters, digits, underscores, or hyphens"
}

ensure_sudo() {
  if command_exists sudo; then
    return
  fi

  log "Installing sudo"
  if command_exists apt-get; then
    apt-get update
    env DEBIAN_FRONTEND=noninteractive apt-get install -y sudo
  elif command_exists dnf; then
    dnf install -y sudo
  elif command_exists yum; then
    yum install -y sudo
  elif command_exists pacman; then
    pacman -Sy --needed --noconfirm sudo
  elif command_exists zypper; then
    zypper --non-interactive install sudo
  else
    die "Could not install sudo: unsupported package manager"
  fi
}

create_user() {
  if id "$username" >/dev/null 2>&1; then
    log "User $username already exists; skipping creation"
    return
  fi

  log "Creating user $username"
  useradd --create-home --shell /bin/bash "$username"

  log "Set a password for $username"
  passwd "$username"
}

grant_sudo_access() {
  local admin_group

  if getent group sudo >/dev/null 2>&1; then
    admin_group="sudo"
  elif getent group wheel >/dev/null 2>&1; then
    admin_group="wheel"
  else
    die "Neither the sudo nor wheel group exists; install and configure sudo first"
  fi

  if id -nG "$username" | tr ' ' '\n' | grep -Fxq "$admin_group"; then
    log "User $username already belongs to $admin_group; skipping"
  else
    log "Adding $username to the $admin_group group"
    usermod --append --groups "$admin_group" "$username"
  fi
}

generate_ssh_key() {
  local user_home ssh_dir private_key public_key key_comment
  user_home="$(getent passwd "$username" | cut -d: -f6)"
  [[ -n "$user_home" ]] || die "Could not determine the home directory for $username"

  ssh_dir="$user_home/.ssh"
  private_key="$ssh_dir/id_ed25519"
  public_key="$private_key.pub"
  key_comment="$username@$(hostname)"

  install -d -m 700 -o "$username" -g "$(id -gn "$username")" "$ssh_dir"

  if [[ -f "$private_key" && -f "$public_key" ]]; then
    log "SSH key already exists at $private_key; keeping it"
  elif [[ -e "$private_key" || -e "$public_key" ]]; then
    die "Only one SSH key file exists under $private_key; inspect the files before continuing"
  else
    log "Generating an Ed25519 SSH key for $username"
    if command_exists runuser; then
      runuser -u "$username" -- ssh-keygen -t ed25519 -C "$key_comment" -f "$private_key" -N ""
    else
      su -s /bin/bash "$username" -c "ssh-keygen -t ed25519 -C '$key_comment' -f '$private_key' -N ''"
    fi
  fi

  log "Copy this public key to GitHub"
  printf '\n'
  cat -- "$public_key"
  printf '\nOpen: https://github.com/settings/ssh/new\n'
  printf 'Press Enter after you have copied the key to GitHub...'
  read -r
}

main() {
  [[ "$(uname -s)" == Linux ]] || die "This script supports Linux only"
  [[ ${EUID:-$(id -u)} -eq 0 ]] || die "Run this script as root: sudo ./setup-linux-user.sh"
  command_exists useradd || die "The useradd command is required"
  command_exists ssh-keygen || die "The ssh-keygen command is required; install the OpenSSH client first"

  prompt_username
  ensure_sudo
  create_user
  grant_sudo_access
  generate_ssh_key

  log "Switching to user $username"
  exec su - "$username"
}

main "$@"
