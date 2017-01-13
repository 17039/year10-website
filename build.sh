#!/bin/bash

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
  echo "This is a PR, exiting"
  exit 0
fi

# only proceed if we have not said to skip the build with [skip build] in the commit message
if [ $CGS_DO_BUILD != "true"]; then
	echo "Skip build, exiting"
	exit 0
fi

# enable error reporting to the console
set -e

# currently in /home/travis/build/CanberraGrammar/year10-website

# build site with jekyll, by default to `_site' folder
bundle exec jekyll build

# cleanup
rm -rf ../year10.cgscomputing.com

# clone repository into /home/travis/build/CanberraGrammar/year10.cgscomputing.com
git clone https://${GH_TOKEN}@github.com/CanberraGrammar/year10-website.git ../year10.cgscomputing.com

# change to the gh-pages branch
cd ../year10.cgscomputing.com
git checkout gh-pages
cd ../year10-website

# delete all files in cloned copy (in case this commit has deleted files)
rm -rf ../year10.cgscomputing.com/*

# copy generated HTML site to `gh-pages' branch
cp -rf _site/* ../year10.cgscomputing.com

# commit and push generated content to `gh-pages' branch
# since repository was cloned in write mode with token auth - we can push there
cd ../year10.cgscomputing.com
git config user.email "cgscomputing@cgs.act.edu.au"
git config user.name "CGSComputing"
git add -A .
git commit -a -m "Travis #$TRAVIS_BUILD_NUMBER"
git push --quiet > /dev/null 2>&1