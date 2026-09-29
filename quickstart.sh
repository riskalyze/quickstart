#!/usr/bin/env bash

# Bail out immediately if something fails
set -euo pipefail

readonly brew_bin="/opt/homebrew/bin/brew"
readonly install_dir="/usr/local/bin"
readonly cast_repo="riskalyze/cast"
readonly cast_asset="cast_darwin_arm64.tar.gz"
readonly gh_scopes="admin:public_key,read:packages"

tmp_dir=$(mktemp -d)

# Prints text in bold.
bold() {
  echo "$(tput bold 2>/dev/null || true)$1$(tput sgr0 2>/dev/null || true)"
}

# Shows a spinner for longer-running tasks.
spinner() {
  local pid=$1
  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  local i=0

  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 8 ))
    printf "\r%s" "${spin:$i:1}"
    sleep .1
  done
  printf "\r"

  wait "$pid"
}

# Cleans up and prints a friendly message if something fails.
exit_handler() {
  local ret=$?
  rm -rf "$tmp_dir"
  if [ $ret -ne 0 ]; then
    bold "💔 Sorry, something didn't work right."
    bold "Please report this problem in an Infrastructure request: https://riskalyze.atlassian.net/servicedesk/customer/portal/3/group/16/create/11112"
  fi
}
trap exit_handler EXIT

unset GITHUB_OAUTH_TOKEN GITHUB_TOKEN GH_TOKEN

bold "👋 Welcome! This script takes care of first-time setup of your computer."

# Install Homebrew if needed and make sure it's on the PATH for this session.
if [ ! -x "$brew_bin" ]; then
  bold "🍺 Installing Homebrew. Please enter your password if prompted."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$brew_bin" shellenv)"

# Make sure /usr/local/bin exists and is writable so cast can update itself.
if [ ! -d "$install_dir" ] || [ ! -w "$install_dir" ]; then
  bold "📁 We need to set up $install_dir. Please enter your password if prompted."
  sudo mkdir -p "$install_dir"
  sudo chown "$(whoami):admin" "$install_dir"
fi

echo "⚙️  Installing dependencies."
(HOMEBREW_NO_ENV_HINTS=true brew install --quiet --formula gh) &
spinner $!

echo "🎉 Great! Now, let's set up your GitHub account."

if ! gh auth status --hostname github.com &>/dev/null; then
  # User is logged out or has never logged in before.
  gh auth login --hostname github.com --scopes "$gh_scopes" --web --git-protocol ssh
else
  # User is logged in; refresh the token if it's missing any required scopes.
  gh_auth_status=$(gh auth status --hostname github.com 2>&1)
  for s in admin:public_key gist read:org read:packages repo; do
    if [[ $gh_auth_status != *"'$s'"* ]]; then
      gh auth refresh --hostname github.com --scopes "$gh_scopes"
      break
    fi
  done
fi

echo "🙌 Wonderful! GitHub is all set."
echo "🧙 Next, let's install Cast (Nitrogen's multi-purpose dev tool)."

(gh release download --repo "$cast_repo" --pattern "$cast_asset" --pattern checksums.txt --dir "$tmp_dir") &
spinner $!
(cd "$tmp_dir" && grep " ${cast_asset}\$" checksums.txt | shasum -a 256 -c - >/dev/null)
tar -xzf "$tmp_dir/$cast_asset" -C "$tmp_dir"
install "$tmp_dir/cast" "$install_dir/cast"

bold "✨ Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
