#!/usr/bin/env bash

# Bail out immediately if something fails
set -eo pipefail

arch=$(uname -m | sed 's/x86_64/amd64/g')

# Prints text in bold.
bold() {
  bold=$(tput bold)
  normal=$(tput sgr0)
  echo "${bold}$1${normal}"
}

# Shows a spinner for longer-running tasks.
spinner() {
  pid=$1
  spin='⣾⣽⣻⢿⡿⣟⣯⣷'

  i=0
  while kill -0 "$pid" 2>/dev/null
  do
    i=$(( (i+1) %8 ))
    printf "\r%s" "${spin:$i:1}"
    sleep .1
  done
  printf "\r"

  wait "${pid}"
  return $?
}

# Prints a friendly message if something fails.
function exit_handler {
  ret=$?
  if [ $ret -ne 0 ]; then
    bold "💔 Sorry, something didn't work right."
    bold "Please report this problem in an Infrastructure request: https://riskalyze.atlassian.net/servicedesk/customer/portal/3/group/16/create/11112"
  fi
}
trap exit_handler EXIT

unset GITHUB_OAUTH_TOKEN
unset GITHUB_TOKEN

bold "👋 Welcome! This script takes care of first-time setup of your computer."

# Make sure /usr/local/bin exists and has the correct permissions.
if [ ! -d /usr/local/bin ]; then
  bold "📁 We need to create a /usr/local/bin folder. Please enter your password if prompted."
  sudo mkdir -p /usr/local/bin
fi

if [ ! -O /usr/local/bin ]; then
  bold "📁 We need to update permissions for /usr/local/bin. Please enter your password if prompted."
  sudo chown -R "$(whoami):admin" /usr/local/bin
fi

# Install a few utilities
echo "⚙️  Installing dependencies."
(HOMEBREW_NO_ENV_HINTS=true brew install --quiet --formula fetch gh) &
spinner $!

echo "🎉 Great! Now, let's set up your GitHub account."

# Check the user's GitHub CLI auth status.
if ! gh auth status &>/dev/null; then
  # User is logged out or has never logged in before; we need to login.
  gh auth login -s admin:public_key,read:packages -w -p ssh
else
  gh_auth_status=$(gh auth status)
  for s in "admin:public_key" "gist" "read:org" "read:packages" "repo"; do
    if [[ ! $gh_auth_status =~ $s ]]; then
      # User is logged in but doesn't have all the right scopes; we need to refresh their token.
      gh auth refresh -s admin:public_key,read:packages
      github_token=$(gh auth token)
      break
    fi
  done
fi

github_token=$(gh auth token)

echo "🙌 Wonderful! GitHub is all set."
echo "🧙 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

# Download and install Cast from the private GitHub repo.
cast_gh_tarball="cast_darwin_${arch}.tar.gz"
(fetch --log-level warn --repo https://github.com/riskalyze/cast --tag "~>2.0" --release-asset="${cast_gh_tarball}" --github-oauth-token "${github_token}" /tmp) &
spinner $!
tar -xzf "/tmp/${cast_gh_tarball}" -C /tmp
install /tmp/cast /usr/local/bin/cast

bold "✨ Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
