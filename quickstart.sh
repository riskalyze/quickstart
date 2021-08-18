#!/usr/bin/env bash

# Bail out immediately if something fails
set -eo pipefail

arch=$(uname -m | sed 's/x86_64/amd64/')

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
bold "🏁 First, we'll install a couple of dependencies."

curl -sSOL "https://github.com/gruntwork-io/fetch/releases/download/v0.4.2/fetch_darwin_${arch}"
install "fetch_darwin_${arch}" /usr/local/bin/fetch

fetch --log-level warn --repo https://github.com/cli/cli --tag "~>1.0" --release-asset="gh_.*_macOS_${arch}.tar.gz" /tmp
tar -xzf /tmp/gh_*_macOS_"${arch}".tar.gz -C /tmp
install /tmp/gh_*_macOS_"${arch}"/bin/gh /usr/local/bin/gh

bold "🎉 Great! Now, let's set up your GitHub account."

if ! gh auth status &>/dev/null; then
  unset GITHUB_TOKEN
  gh auth login -w
fi

bold "🙌 Wonderful! GitHub is all set."
bold "🧙 Next, we'll install Cast (Riskalyze's multi-purpose dev tool)."

github_token=$(gh auth status -t 2> >(grep -oh 'gho.*'))
cast_gh_tarball="cast_darwin_${arch}.tar.gz"
fetch --log-level warn --repo https://github.com/riskalyze/cast --tag "~>1.0" --release-asset="${cast_gh_tarball}" --github-oauth-token "${github_token}" /tmp
tar -xzf "/tmp/${cast_gh_tarball}" -C /usr/local/bin cast

bold "✨ Success! You are now ready to finish setting things up. Please run 'cast system install' to continue."
