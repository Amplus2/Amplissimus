#!/bin/sh
shortversion='4.2'
commitcount=$(git rev-list @ --count)
echo "::set-output name=commit::$(git rev-parse @)"
echo "::set-output name=short_version::$shortversion"
echo "::set-output name=commit_count::$commitcount"
echo "::set-output name=version::$shortversion.$(($commitcount - 1400))"
