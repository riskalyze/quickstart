#!/usr/bin/env bash

red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'

echo "👋 Welcome! This script takes care of first-time setup of your computer."
echo "🏁 First, let's make sure Homebrew is installed."

if ! command -v brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Great! Now, let's set up your GitHub account."

if ! command -v gh; then
  brew install gh
fi

if ! gh auth status 2>/dev/null; then 
  gh auth login -w
fi

echo "🙌 Wonderful! GitHub is all set."
echo "🪄 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

brew tap riskalyze/homebrew-taps
brew install cast

echo "✨ Success! You are now ready to finish setting things up. Please run `cast system install` to continue."
