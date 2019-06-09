#!/bin/bash
# Exercise 3a - Create User and Repositories
# Reference URL -
#   REST API -  https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
#   FILESPEC - https://www.jfrog.com/confluence/display/RTF/Using+File+Specs
#   JFROG CLI - https://www.jfrog.com/confluence/display/CLI/JFrog+CLI
#   YAML Configuration - https://www.jfrog.com/confluence/display/RTF/YAML+Configuration+File
#
# Remember to update local /etc/hosts with the orbitera ip address to jfrog.local
#
# Variables to be set
ART_URL="http://jfrog.local/artifactory"
ART_PASSWORD="qwsDx6M1fr"
USER="admin"
ACCESS_TOKEN=""
USER_APIKEY=""
SERVER_ID="us-site"

REMOTE_ARTIFACTORY="http://35.224.137.48:8092/artifactory"
REMOTE_USER="admin"
REMOTE_PASSWORD="cSstW3XMOb"
REMOTE_ACCESS_TOKEN=""
REMOTE_ART_ID="es-site"
REPOSITORY_YAML_LOC="resources/module3/repo.yaml"
REMOTE_ART_APIKEY=""

#Dependencies
TOMCAT="tomcat-local/org/apache/apache-tomcat/apache-tomcat-*.tar.gz"
JDK="tomcat-local/java/jdk-8u91-linux-x64.tar.gz"
HELM="helm-local/helm"
DEPENDENCY_FILESPEC="resources/module3/swampupfilespecUpload.json"
AQL_IMPL="resources/module3/junitfilter.aql"
LARGESTFOLDER="resources/module3/largestfolder.aql"
CLEANUP="resources/module3/cleanup.aql"
SUBMITTER="resources/module3/submitter.aql"


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

# Retrieve API for Artifactory US Key
getUSUserSecurity () {
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
       "${ART_URL}"/api/security/token -d "username=${USER}" -d "scope=member-of-groups:admin-group"))
  ACCESS_TOKEN=$(echo ${response[@]} | jq '.access_token' | sed 's/"//g')
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X GET -H 'Content-Type: application/json' "${ART_URL}"/api/security/apiKey))
  USER_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${USER}:${USER_APIKEY} and access token: ${ACCESS_TOKEN}"

}

getEUUserSecurity () {
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
       "${REMOTE_ARTIFACTORY}"/api/security/token -d "username=${REMOTE_USER}" -d "scope=member-of-groups:admin-group"))
  REMOTE_ACCESS_TOKEN=$(echo ${response[@]} | jq '.access_token' | sed 's/"//g')
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X POST -H 'Content-Type: application/json' "${REMOTE_ARTIFACTORY}"/api/security/apiKey))
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X GET -H 'Content-Type: application/json' "${REMOTE_ARTIFACTORY}"/api/security/apiKey))
  REMOTE_ART_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${REMOTE_USER}:${REMOTE_ART_APIKEY} and access token: ${REMOTE_ACCESS_TOKEN}"

}

createRepo () {
  echo "Creating Repositories"
  local response=($(curl -s -u"admin":"${ART_PASSWORD}" -X PATCH -H "Content-Type: application/yaml" \
       "${ART_URL}"//api/system/configuration -T $1))
  echo ${response[@]}
}

#Exercise 3b - JFROG CLI Download
loginArt () {
   echo "Log into Artifactories"
   curl -fLs jfrog https://getcli.jfrog.io | sh
   jfrog rt c ${REMOTE_ART_ID} --url=${REMOTE_ARTIFACTORY} --apikey=${REMOTE_ART_APIKEY}
   jfrog rt c ${SERVER_ID} --url=${ART_URL} --apikey=${USER_APIKEY}
   jfrog rt c show
}

# Download the required dependencies from remote artifactory instance (jfrogtraining)
# paths -
#    tomcat-local/org/apache/apache-tomcat/
#    tomcat-local/java/
#    generic-local/helm
# Similar to using third party binaries that are not available from remote repositories.
downloadDependencies () {
  echo "Fetch tomcat for the later docker framework build"
  jfrog rt dl ${TOMCAT} ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready
  echo "Fetch java for the later docker framework build"
  jfrog rt dl ${JDK} ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready
  echo "Fetch Helm Client for later helm chart"
  jfrog rt dl ${HELM} ./ --server-id ${REMOTE_ART_ID} --props=swampup2019=ready
}

# Exercise 3c - Filespec upload with properties
uploadFileSpec () {
  echo "Uploading binaries to Artifactory"
  jfrog rt u --spec $1 --server-id ${SERVER_ID}
}

# Exercise 3d-b - AQL find all jars with junit-4.11.jar
# You have just been informed that “junit-4.11.jar” class library has a serious null pointer exception 
# issue. You must immediately find all products that have this issue and have development build with 
# latest remediation. 
aqlsearch () {
  echo "Listing all jars with junit-4.11.jar; AQL file: $1"
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST  "${ART_URL}"/api/search/aql -T $1))
  local jarList=$(echo ${response[@]} | jq '.results[].archives[].items[] | .repo + "/" + .path + "/" + .name ')
  for jar in "${jarList[@]}"
  do
     printf "${jar} \n"
  done
}

# Exercise 3d-c - AQL find latest Docker build
# Write a function to print the latest docker-app tag.  i.e. Latest Tag: 303; Do not include ”latest” 
# because it is not immutable.  Repo is docker-prod-local; and docker image is "docker-app" Use main
# main artifactory US. 
latestDockerTag () {
  echo "Find latest docker tag"
   REPO=$1
   IMAGE=$2
   aqlString='items.find({
      "repo":"'$REPO'",
      "type":"folder",
      "$and":[
        {"path":{"$match":"'$IMAGE'*"}},
        {"name":{"$nmatch":"latest"}}]}
      ).include("path","created","name").sort({"$desc":["created"]}).limit(1)'
   local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -H 'Content-Type: text/plain' -X POST "${ART_URL}"/api/search/aql -d "${aqlString}"))
   tag=$(echo ${response[@]} | jq '.results[0].name')
   printf "'$IMAGE':'$tag'\n"
}

# Exercise 3d-d - Clean Up Example
# List all files that meet the following criteria:
# - They are the largest 100 files which were created by the “jenkins” user.
# - Their extension is either tar or zip.
# - They downloaded less than 1.
# - Their size is greater than 100Mb
# - List the build that produces them. 
generalAQLSearch () {
  echo "General AQL Search"
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST  "${ART_URL}"/api/search/aql -T $1))
  local jarList=$(echo ${response[@]} | jq '.results[]')
  for jar in "${jarList[@]}"
  do
     printf "${jar} \n"
  done
}


main () {
   #Exercise 3a 
   #createUser "swampupdev2019" "9YF*9@UT4Ca^CDeF"
   #createUser "swampupops2019" "9YF*9@UT4Ca^CDeF"
   #getUSUserSecurity
   #getEUUserSecurity
   #createRepo "$(dirname "$PWD")/${REPOSITORY_YAML_LOC}"

   #Exercise 3b 
   #loginArt
   #downloadDependencies

   #Exercise 3c
   #uploadFileSpec "$(dirname "$PWD")/${DEPENDENCY_FILESPEC}"

   #Exercise 3d 
   #generalAQLSearch "$(dirname "$PWD")/${SUBMITTER}" #Excerise 3d-a
   #aqlsearch "$(dirname "$PWD")/${AQL_IMPL}" #Exercise 3d-b
   #latestDockerTag "docker-prod-local" "docker-app" #Exercise 3d-c
   #generalAQLSearch "$(dirname "$PWD")/${CLEANUP}"      #Excerise 3d-d
   #generalAQLSearch "$(dirname "$PWD")/${LARGESTFOLDER}" #Excerise 3d-e
}

main


