#!/bin/bash
# Exercise 4 - Create User and Repositories
# Reference URL -
#   REST API -  https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
#   FILESPEC - https://www.jfrog.com/confluence/display/RTF/Using+File+Specs
#   JFROG CLI - https://www.jfrog.com/confluence/display/CLI/JFrog+CLI
#   YAML Configuration - https://www.jfrog.com/confluence/display/RTF/YAML+Configuration+File

# Variables
ART_URL="http://35.202.159.126/artifactory"
ARTDOCKER_REGISTRY="jfrogbeta.com:5001"
ART_PASSWORD="QbyTDIE759"
USER="swamp2018"
ACCESS_TOKEN=""
USER_APIKEY=""
SERVER_ID="swampup2018"
REMOTE_ART_ID="jfrogtraining"

# Exercise 4 - Create User and Repositories
createUser () {
  curl -s -uadmin:"${ART_PASSWORD}" -X PUT -H 'Content-Type: application/json' \
      "${ART_URL}"/api/security/users/${USER} -d '{
         "name":"'"${USER}"'",
         "password":"'"${ART_PASSWORD}"'",
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
  local response=($(curl -s -u"${USER}":"${USER_APIKEY}" -X PATCH -H "Content-Type: application/yaml" \
       "${ART_URL}"/api/system/configuration -T $1))
  echo ${response[@]}
}

# Exercise 5 - JFrog CLI
loginArt () {
   echo "Log into Artifactories"
   curl -fLs jfrog https://getcli.jfrog.io | sh
   ./jfrog rt c ${REMOTE_ART_ID} --url=https://jfrogtraining.jfrog.io/jfrogtraining/ --apikey=AKCp2Vo711zssGkjSUgXYc32HVfNhUbddJ9uLGRhQDpDTWuKr7EFeZorbpbiFfBu2haZ81YLX
   ./jfrog rt c ${SERVER_ID} --url=${ART_URL} --apikey=${USER_APIKEY}
}

downloadDependenciesTools () {
# Download the required dependencies from remote artifactory instance (jfrogtraining)
# paths -
#    tomcat-local/org/apache/apache-tomcat/
#    tomcat-local/java/
#    generic-local/helm
# Similar to using third party binaries that are not available from remote repositories.

  echo "Fetch tomcat for the later docker framework build"
  ./jfrog rt dl tomcat-local/org/apache/apache-tomcat/apache-tomcat-8.0.32.tar.gz ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true
  echo "Fetch java for the later docker framework build"
  ./jfrog rt dl tomcat-local/java/jdk-8u91-linux-x64.tar.gz ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true
  echo "Fetch Helm Client for later helm chart"
  ./jfrog rt dl generic-local/helm ./ --server-id ${REMOTE_ART_ID}
}

# Exercise 5 - Filespec upload with properties
uploadFileSpec () {
  echo "Uploading binaries to Artifactory"
  ./jfrog rt u --spec $1 --server-id ${SERVER_ID}
}

# Exercise 6a - AQL find all jars with impl.class
aqlsearch () {
  echo "Listing all jars with impl.class"
  local response=($(curl -s -u"${USER}":"${USER_APIKEY}" -X POST  "${ART_URL}"/api/search/aql -T $1))
  local jarList=$(echo ${response[@]} | jq '.results[].archives[].items[] | .repo + "/" + .path + "/" + .name ')
  for jar in "${jarList[@]}"
  do
     printf "${jar} \n"
  done
}

# Exercise 6b - AQL find latest Docker build
latestDockerTag () {
  echo "Find latest docker tag"
   REPO=$1
   IMAGE=$2
   aqlString='items.find({"repo":"'$REPO'","type":"folder","$and":[{"path":{"$match":"'$IMAGE'*"}},{"path":{"$nmatch":"'$IMAGE'/latest"}}]}).include("path","created","name").sort({"$desc":["created"]}).limit(1)'
   local response=($(curl -s -u"${USER}":"${USER_APIKEY}" -H 'Content-Type: text/plain' -X POST "${ART_URL}"/api/search/aql -d "${aqlString}"))
   tag=$(echo ${response[@]} | jq '.results[0].name')
   printf "'$IMAGE':'$tag'\n"
}

main () {
   createUser
   getUserSecurity
   createRepo "training-repo.yaml"
   loginArt
   downloadDependenciesTools
   uploadFileSpec "swampupfilespecUpload.json"
   aqlsearch "aql/implfilter.aql"
   latestDockerTag "docker-prod-local" "docker-app"
}

main

