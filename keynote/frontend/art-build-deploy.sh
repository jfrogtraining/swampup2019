#!/usr/bin/env bash


usage() {
    echo "Deploy a vue-based build to Artifactory using npm"
    echo "Usage: $1 artifactory address"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

artiUrl="$1"

#setup npm locally
curl -u admin:password http://${artiUrl}:80/artifactory/api/npm/auth > ~/.npmrc
echo "email = youremail@email.com" >> ~/.npmrc
npm config set registry http://${artiUrl}/artifactory/api/npm/npm-libs-local/

# remove existing artifact
curl -uadmin:password -XDELETE http://${artiUrl}:80/artifactory/npm-libs-local/frontend/-/frontend-3.0.0.tgz

# build and publish
npm i && npm run build &&  npm publish

