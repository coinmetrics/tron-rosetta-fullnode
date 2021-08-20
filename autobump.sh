#!/bin/sh

# Sets up the local SSH bits for autobump

if test -n "$CI"
then

if test ! -n "$GIT_SSH_PRIV_KEY" ; then exit 1 ; fi  # we do need a key
eval $(ssh-agent -s)
echo "$GIT_SSH_PRIV_KEY" | tr -d '\r' | ssh-add -
git config --global user.email "autobumper@localhost"
git config --global user.name "Auto Bumper"
mkdir -p ~/.ssh
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

fi


# Check for updated version and attempt to bump our version if a newer release exists

# get our version and upstream latest
export OUR_VERSION="${VERSION:-$(cat version.txt)}"
export LATEST_VERSION="$(sh get_version.sh)"
# compare
test "$LATEST_VERSION" = "$OUR_VERSION" && exit 0 || true

# make sure a branch isn't already open for this version
git pull "$CI_REPOSITORY_URL" "autobump_$LATEST_VERSION" && exit 0 || true
# make a branch and bump the version in it
git checkout -B "autobump_$LATEST_VERSION" && echo "$LATEST_VERSION" > version.txt && git commit -m "auto-bump version to $LATEST_VERSION" version.txt
# push our branch with push options to open a merge request which will get automatically merged if it passes CI
git push -o merge_request.create -o merge_request.target=${CI_DEFAULT_BRANCH} -o merge_request.merge_when_pipeline_succeeds git@gitlab.com:${CI_PROJECT_PATH}.git "autobump_$LATEST_VERSION"
