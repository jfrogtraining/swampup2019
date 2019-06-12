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
ARTDOCKER_REGISTRY="jfrog.local:5000"

REMOTE_ARTIFACTORY="http://jfrog.local:8092/artifactory"
REMOTE_USER="admin"
REMOTE_PASSWORD="cSstW3XMOb"
REMOTE_ART_ID="es-site"
REPOSITORY_YAML_LOC="resources/module3/repo.yaml"
REMOTE_ACCESS_TOKEN=""
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

#Build Names
STEP1_BLDNAME="step1-create-application-war-file"
STEP2_BLDNAME="step2-create-docker-image-template"
STEP3_BLDNAME="step3-create-docker-image-product"

# Exercise 3a - Create User and Repositories
createUser () {
  echo "Creating User: $1"
  curl  -uadmin:"${ART_PASSWORD}" -X PUT -H 'Content-Type: application/json' \
        "${ART_URL}"/<TBD>/$1 -d '{
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
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X <TBD> -H 'Content-Type: application/json' "${ART_URL}"/<TBD>))
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X <TBD> -H 'Content-Type: application/json' "${ART_URL}"/<TBD>))
  USER_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${USER}:${USER_APIKEY} and access token: ${ACCESS_TOKEN}"

}

getEUUserSecurity () {
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
       "${REMOTE_ARTIFACTORY}"/api/security/token -d "username=${REMOTE_USER}" -d "scope=member-of-groups:admin-group"))
  REMOTE_ACCESS_TOKEN=$(echo ${response[@]} | jq '.access_token' | sed 's/"//g')
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X <TBD> -H 'Content-Type: application/json' "${REMOTE_ARTIFACTORY}"/<TBD>))
  local response=($(curl -s -u"${REMOTE_USER}":"${REMOTE_PASSWORD}" -X <TBD> -H 'Content-Type: application/json' "${REMOTE_ARTIFACTORY}"/<TBD>))
  REMOTE_ART_APIKEY=$(echo ${response[@]} | jq '.apiKey' | sed 's/"//g')
  echo "User api key: ${REMOTE_USER}:${REMOTE_ART_APIKEY} and access token: ${REMOTE_ACCESS_TOKEN}"

}

createRepo () {
  echo "Creating Repositories"
  local response=($(curl -s -u"admin":"${ART_PASSWORD}" -X PATCH -H "Content-Type: application/yaml" \
       "${ART_URL}"/<TBD> -T $1))
  echo ${response[@]}
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

   #Exercise Step1-Create1-application
   #gradle_build_number=1
   #step1-create1-application ${gradle_build_number}

   #Exercise Step2-Create-Docker-Image
   #docker_fmr_build_number=1
   #step2-create-docker-image-template ${docker_fmr_build_number}

   #Exercise Step3-Create Docker App
   #docker_app_build_number=1
   #step3-create-docker-image-product ${docker_app_build_number}
}

main


