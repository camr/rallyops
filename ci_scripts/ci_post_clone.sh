#!/bin/sh
set -e

# Install commit-msg hook so conventional-commit enforcement is active during cloud builds.
cp "$CI_PRIMARY_REPOSITORY_PATH/hooks/commit-msg" \
   "$CI_PRIMARY_REPOSITORY_PATH/.git/hooks/commit-msg"
chmod +x "$CI_PRIMARY_REPOSITORY_PATH/.git/hooks/commit-msg"
