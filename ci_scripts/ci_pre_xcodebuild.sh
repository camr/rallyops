#!/bin/sh
set -e

echo "=== Xcode Cloud Build Info ==="
echo "Workflow:      $CI_WORKFLOW"
echo "Action:        $CI_XCODEBUILD_ACTION"
echo "Branch:        $CI_BRANCH"
echo "Commit:        $CI_COMMIT"
echo "Build number:  $CI_BUILD_NUMBER"
echo "Bundle ID:     dev.camr.rallyops"
echo "=============================="
