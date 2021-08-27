#!/usr/bin/env bash

# Bail out immediately if something fails
set -eo pipefail

arch=$(uname -m | sed 's/x86_64/amd64/')
bold=$(tput bold)
normal=$(tput sgr0)

bold() {
  echo "${bold}$1${normal}"
}

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

# Print a friendly message if something fails
function exit_handler {
  ret=$?
  if [ $ret -ne 0 ]; then
    bold "💔 Sorry, something didn't work right."
    bold "Please report this problem in an Infrastructure request: https://riskalyze.atlassian.net/servicedesk/customer/portal/3/group/16/create/11112"
  fi
}
trap exit_handler EXIT

bold "👋 Welcome! This script takes care of first-time setup of your computer."
echo "🏁 First, let's install a couple of dependencies."

if [ ! -d /usr/local/bin ]; then
  bold "📁 We need to create a /usr/local/bin folder. Please enter your password when prompted."
  sudo mkdir -p /usr/local/bin
  sudo chown -R "$(whoami):admin" /usr/local/bin
fi

(curl -o /tmp/fetch -sfSL "https://github.com/gruntwork-io/fetch/releases/download/v0.4.2/fetch_darwin_${arch}") &
spinner $!
install /tmp/fetch /usr/local/bin/fetch

(fetch --log-level warn --repo https://github.com/cli/cli --tag "~>2.0" --release-asset="gh_.*_macOS_amd64.tar.gz" /tmp) &
spinner $!
tar -xzf /tmp/gh_*_macOS_amd64.tar.gz --strip-components 2 -C /tmp
install /tmp/gh /usr/local/bin/gh

echo "🎉 Great! Now, let's set up your GitHub account."

if ! gh auth status &>/dev/null; then
  unset GITHUB_TOKEN
  gh auth login -w
fi

echo "🙌 Wonderful! GitHub is all set."
echo "🧙 Next, let's install Cast (Riskalyze's multi-purpose dev tool)."

github_token=$(gh auth status -t 2> >(grep -oh 'gho.*'))
cast_gh_tarball="cast_darwin_${arch}.tar.gz"
(fetch --log-level warn --repo https://github.com/riskalyze/cast --tag "~>1.0" --release-asset="${cast_gh_tarball}" --github-oauth-token "${github_token}" /tmp) &
spinner $!
tar -xzf "/tmp/${cast_gh_tarball}" -C /tmp
install /tmp/cast /usr/local/bin/cast

bold "✨  Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
