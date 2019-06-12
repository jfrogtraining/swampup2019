#!/bin/bash

usage() {
    echo "Deploy a maven-based build to Artifactory using Artifactory maven plugin"
    echo "Usage: $1 buildnumber"
    echo "Usage: $2 mavenSettingsFile"


    exit 1
}

if [ -z "$1" ]; then
    usage
fi

buildnumber="$1"

if [ "$2" ]; then
    mavenSettingsFile=$2
else
    mavenSettingsFile="settings.xml"
fi

if [ ! -f "$mavenSettingsFile" ]; then
    echo "ERROR: file $mavenSettingsFile does not exist!"
    exit 1
fi

mvn deploy -Dbuildnumber="$buildnumber" -s $mavenSettingsFile