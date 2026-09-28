# Quickstart

Start here to configure your laptop for development at Nitrogen!

## Requirements

- An Apple Silicon Mac
- A GitHub account with access to the `riskalyze` organization

The script installs [Homebrew](https://brew.sh) if it isn't already installed.

## Instructions

Paste this in a terminal and hit enter:

```shell
qs="$(mktemp)" && curl -fsSL https://raw.githubusercontent.com/riskalyze/quickstart/main/quickstart.sh -o "$qs" && bash "$qs"
```

When it finishes, run `cast system install` to finish configuring your system.
