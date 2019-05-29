#!/bin/bash
# Exercise 3a - Create User and Repositories
# Reference URL -
#   REST API -  https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
#   FILESPEC - https://www.jfrog.com/confluence/display/RTF/Using+File+Specs
#   JFROG CLI - https://www.jfrog.com/confluence/display/CLI/JFrog+CLI
#   YAML Configuration - https://www.jfrog.com/confluence/display/RTF/YAML+Configuration+File

# Variables
ART_URL="http://jiracloud-art-test.jfrog.team/artifactory"
ART_PASSWORD="pFc!nV8HZ6m-UBC1"
USER="swamp2018"
ACCESS_TOKEN=""
USER_APIKEY=""
SERVER_ID="swampup2019"
REMOTE_ARTFACTORY="https://jfrogtraining.jfrog.io/jfrogtraining/"
REMOTE_ART_ID="jfrogtraining"
REMOTE_ART_APIKEY="AKCp2Vo711zssGkjSUgXYc32HVfNhUbddJ9uLGRhQDpDTWuKr7EFeZorbpbiFfBu2haZ81YLX"

#Dependencies
TOMCAT="tomcat-local/org/apache/apache-tomcat/apache-tomcat-*.tar.gz"
JDK="tomcat-local/java/jdk-8u91-linux-x64.tar.gz"
HELM="generic-local/helm"

# Exercise 3a - Create User and Repositories
createUser () {
  echo "Creating User: $1"
  curl  -uadmin:"${ART_PASSWORD}" -X PUT -H 'Content-Type: application/json' \
      "${ART_URL}"/api/security/users/$1 -d '{
         "name":"'"$1"'",
         "password":"'"$2"'",
         "email":"null@jfrog.com",
         "admin":true,
         "groups":["readers"]
       }'
}

getUserSecurity () {
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
       "${ART_URL}"/api/security/token -d "username=${USER}" -d "scope=member-of-groups:admin-group"))
  ACCESS_TOKEN=$(echo ${response[@]} | jq '.access_token' | sed 's/"//g')

  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X GET -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  USER_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${USER}:${USER_APIKEY} and access token: ${ACCESS_TOKEN}"
}

createRepo () {
  echo "Creating Repositories"
  local response=($(curl -s -u"admin":"${ART_PASSWORD}" -X PATCH -H "Content-Type: application/yaml" \
       "${ART_URL}"/api/system/configuration -T $1))
  echo ${response[@]}
}

#Exercise 3b - JFROG CLI Download
loginArt () {
   echo "Log into Artifactories"
   curl -fLs jfrog https://getcli.jfrog.io | sh
   ./jfrog rt c ${REMOTE_ART_ID} --url=${REMOTE_ARTFACTORY} --apikey=${REMOTE_ART_APIKEY}
   ./jfrog rt c ${SERVER_ID} --url=${ART_URL} --apikey=${USER_APIKEY}
}

# Download the required dependencies from remote artifactory instance (jfrogtraining)
# paths -
#    tomcat-local/org/apache/apache-tomcat/
#    tomcat-local/java/
#    generic-local/helm
# Similar to using third party binaries that are not available from remote repositories.
downloadDependenciesTools () {
  echo "Fetch tomcat for the later docker framework build"
  ./jfrog rt dl ${TOMCAT} ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready
  echo "Fetch java for the later docker framework build"
  ./jfrog rt dl ${JDK} ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready
  echo "Fetch Helm Client for later helm chart"
  ./jfrog rt dl ${HELM} ./ --server-id ${REMOTE_ART_ID} --props=swampup2019=ready
}


main () {
#   createUser "swampupdev2019" "9YF*9@UT4Ca^CDeF"
#   createUser "swampupops2019" "9YF*9@UT4Ca^CDeF"
#   createRepo "/Users/stanleyf/git/swampup2019/su-116-advance-automation/module3/repo.yaml"
   getUserSecurity
   loginArt
   downloadDependenciesTools
}

main

