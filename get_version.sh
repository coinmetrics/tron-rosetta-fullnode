#!/bin/sh

# Check for the latest upstream release

GITHUB_REPO=tronprotocol/tron-rosetta-api

curl --silent "https://api.github.com/repos/${GITHUB_REPO}/releases/latest"  | jq .tag_name | sed 's/^"v//' | sed 's/"$//'

