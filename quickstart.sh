#!/usr/bin/env bash

echo "👋 Welcome! This script takes care of first-time setup of your computer."
echo "🏁 First, let's make sure Homebrew is installed."

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Great! Now, let's set up your GitHub account."

if ! command -v gh &>/dev/null; then
  brew install gh
fi

if ! gh auth status &>/dev/null; then 
  gh auth login -w
fi

echo "🙌 Wonderful! GitHub is all set."
echo "🪄 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

if ! command -v cast &>/dev/null; then
  brew tap riskalyze/cast git@github.com:riskalyze/cast
  brew install cast
fi

echo "✨ Success! You are now ready to finish setting things up. Please run `cast system install` to continue."
