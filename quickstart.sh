#!/usr/bin/env bash

ARCH=$(uname -m | sed 's/x86_64/amd64/')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

echo "👋 Welcome! This script takes care of first-time setup of your computer."
echo "🏁 First, let's make sure Homebrew is installed."

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Great! Now, let's set up your GitHub account."

brew bundle --no-upgrade --file=- <<-EOF
brew "fetch"
brew "gh"
EOF

if ! gh auth status &>/dev/null; then
  gh auth login -w
fi

echo "🙌 Wonderful! GitHub is all set."
echo "🪄 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

if ! command -v cast &>/dev/null; then
  GITHUB_OAUTH_TOKEN=$(gh auth status -t 2> >(grep -oh 'gho.*'))
  CAST_TARBALL="cast_${OS}_${ARCH}.tar.gz"
  fetch --repo https://github.com/riskalyze/cast --tag "~>1.0" --release-asset="${CAST_TARBALL}" --github-oauth-token "${GITHUB_OAUTH_TOKEN}" /tmp
  tar -xzvf /tmp/"${CAST_TARBALL}" -C /usr/local/bin cast
fi

echo "✨ Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
