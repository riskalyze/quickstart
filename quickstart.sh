#!/usr/bin/env bash

# Bail out immediately if something fails
set -eo pipefail

ARCH=$(uname -m | sed 's/x86_64/amd64/')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

bold=$(tput bold)
normal=$(tput sgr0)

bold() {
  echo "${bold}$1${normal}"
}

# Print a friendly message if something fails
function exit_handler {
  ret=$?
  if [ $ret -ne 0 ]; then
    bold "💔 Sorry, something didn't work right. Please report this problem in an Infrastructure request: https://riskalyze.atlassian.net/servicedesk/customer/portal/3/group/16/create/11112"
  fi
}
trap exit_handler EXIT

bold "👋 Welcome! This script takes care of first-time setup of your computer."
bold "🏁 First, let's make sure Homebrew is installed."

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

bold "🍺 Great! Now, let's set up your GitHub account."

brew bundle --quiet --no-upgrade --file=- <<-EOF
brew "fetch"
brew "gh"
EOF

if ! gh auth status &>/dev/null; then
  unset GITHUB_TOKEN
  gh auth login -w
fi

bold "🙌 Wonderful! GitHub is all set."
bold "🧙 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

GITHUB_OAUTH_TOKEN=$(gh auth status -t 2> >(grep -oh 'gho.*'))
CAST_TARBALL="cast_${OS}_${ARCH}.tar.gz"
fetch --log-level warn --repo https://github.com/riskalyze/cast --tag "~>1.0" --release-asset="${CAST_TARBALL}" --github-oauth-token "${GITHUB_OAUTH_TOKEN}" /tmp
tar -xzf /tmp/"${CAST_TARBALL}" -C /usr/local/bin cast

bold "✨ Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
