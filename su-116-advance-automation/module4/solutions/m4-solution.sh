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

#Build Names
STEP1_BLDNAME="step1-create-application-war-file"
STEP2_BLDNAME="step2-create-docker-image-template"
STEP3_BLDNAME="step3-create-docker-image-product"


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
   jfrog rt c ${SERVER_ID} --url=${ART_URL} --password=${ART_PASSWORD}
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

# similar to downloadDependencies but with build name and number so that it can be included in buildinfo as dependencies
downloadDependenciesBuildInfo () {
  echo "Fetch tomcat for the later docker framework build"
  b_name=$1
  b_no=$2

  jfrog rt dl ${TOMCAT} ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready --build-name=${b_name} --build-number=${b_no}
  echo "Fetch java for the later docker framework build"
  jfrog rt dl ${JDK} ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=swampup2019=ready --build-name=${b_name} --build-number=${b_no}
  echo "Fetch Helm Client for later helm chart"
  jfrog rt dl ${HELM} ./ --server-id ${REMOTE_ART_ID} --props=swampup2019=ready --build-name=${b_name} --build-number=${b_no}
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

# Exercise Step1-STEP1-CREATE-APPLICATION-WAR-FILE
#
# When running the build “jfrog rt gradlec” you will e prompt for the following: 
# Is the Gradle Artifactory Plugin already applied in the build script (y/n) [n]? Y
# Use Gradle wrapper (y/n) [n]? Y
# Resolve dependencies from Artifactory (y/n) [y]? Y
# Set Artifactory server ID (press Tab for options) [jfrogtraining]: swampup2018
# Set repository for dependencies resolution (press Tab for options): jcenter
# Deploy artifacts to Artifactory (y/n) [y]? Y
# Set Artifactory server ID (press Tab for options) [jfrogtraining]: swampup2018Set repository for artifacts deployment (press Tab for options): gradle-release
# Deploy Maven descriptor (y/n) [n]? Y
# Deploy Ivy descriptor (y/n) [n]? n

step1-create1-application () {
   echo "step1-create1-application - building war application"
   build_name="${STEP1_BLDNAME}"
   build_no=$1
   rootDir=$PWD

   git clone https://github.com/jfrogtraining/project-examples 
   cd project-examples/gradle-examples/4/gradle-example-publish
   chmod 775 gradlew
   echo "Build Number is ${build_no}"
   # create a build configuration file for a gradle build. The command's argument is a path to a new file which will be created by the command
   jfrog rt gradlec gradle-example.config 
   # To run a gradle build
   echo "Running gradle build"
   jfrog rt gradle "clean artifactoryPublish -b ./build.gradle" gradle-example.config --build-name=${build_name} --build-number=${build_no}
   # Environment variables are collected using the build-collect-env (bce) command.
   echo "Collecting environment varilable for buildinfo"
   jfrog rt bce ${build_name} ${build_no}
   echo "Collecting git info i.e. jira tickets"
   jfrog rt bag ${build_name} ${build_no} "${rootDir}/project-examples"
   # publish the accumulated build information for a build to Artifactory
   jfrog rt bp ${build_name} ${build_no} --server-id ${SERVER_ID}
   echo "Successfully build application"
   cd ${rootDir}
}

step2-create-docker-image-template () {
  echo "step2-create-docker-image-template  - building docker base for web applications"
  docker_fmr_build_name="${STEP2_BLDNAME}"
  docker_fmr_build_no=$1
  rootDir=$PWD

  cd step2-dockerframework

  echo "Downloading dependencies"
  downloadDependenciesBuildInfo ${docker_fmr_build_name} ${docker_fmr_build_no}

  TAGNAME="${ARTDOCKER_REGISTRY}/docker-framework:${1}"
  TAGNAMELATEST="${ARTDOCKER_REGISTRY}/docker-framework:latest"
  echo $TAGNAME
  docker login $ARTDOCKER_REGISTRY -u $USER -p $ART_PASSWORD
  echo "Building docker base image"
  docker build -t $TAGNAME .
  docker tag $TAGNAME $TAGNAMELATEST
  echo "Publishing docker freamework base image to artifactory"
  jfrog rt dp $TAGNAME docker-virtual --build-name=${docker_fmr_build_name} --build-number=${docker_fmr_build_no} --server-id=${SERVER_ID}
  jfrog rt dp $TAGNAMELATEST docker-virtual --build-name=${docker_fmr_build_name} --build-number=${docker_fmr_build_no} --server-id=${SERVER_ID}
  echo "Collecting environment variable for buildinfo"
  jfrog rt bce ${docker_fmr_build_name} ${docker_fmr_build_no}
  echo  "publishing buildinfo"
  jfrog rt bp ${docker_fmr_build_name} ${docker_fmr_build_no} --server-id=${SERVER_ID}
  docker rmi $TAGNAME
  docker rmi $TAGNAMELATEST
  echo "Successfully deployed framework"
  cd ${rootDir}
}

step3-create-docker-image-product () {
  echo "step3-create-docker-image-product - building docker app "
  docker_app_build_name="${STEP3_BLDNAME}"
  docker_app_build_no=$1
  rootDir=$PWD

  cd step3-dockerapp
  echo "Downloading dependencies"
  getLatestGradleWar  "gradle-release-local" ${docker_app_build_name} ${docker_app_build_no}

  TAGNAME="${ARTDOCKER_REGISTRY}/docker-app:${1}"
  echo $TAGNAME
  docker login $ARTDOCKER_REGISTRY -u $USER -p $ART_PASSWORD
  echo "Building docker app image"
  docker build -t $TAGNAME .

  Test docker app
  docker run -d -p 9191:8181 $TAGNAME
  sleep 10
  curl --retry 10 --retry-delay 5 -v http://localhost:9191

  #Publish docker app
  echo "Publishing docker freamework base image to artifactory"
  jfrog rt dp $TAGNAME docker-virtual --build-name=${docker_app_build_name} --build-number=${docker_app_build_no} --server-id=${SERVER_ID}
  
  echo "Collecting environment variable for buildinfo"
  jfrog rt bce ${docker_app_build_name} ${docker_app_build_no}
  
  echo  "publishing buildinfo"
  jfrog rt bp ${docker_app_build_name} ${docker_app_build_no} --server-id=${SERVER_ID}
  docker rmi $TAGNAME
  echo "Successfuily deployed docke app"
  cd ${rootDir}
}

getLatestGradleWar () {
   REPO=$1
   gb_name=$2
   gb_no=$3

   aqlString='items.find ({"repo":{"$eq":"gradle-release-local"},"name":{"$match":"webservice-*.jar"},"@build.name":"'${STEP1_BLDNAME}'"}).include("created","path","name").sort({"$desc" : ["created"]}).limit(1)'
   local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -H 'Content-Type: text/plain' -X POST "${ART_URL}"/api/search/aql -d "${aqlString}"))
   echo ${response[@]}
   path=$(echo ${response[@]} | jq '.results[0].path' | sed 's/"//g')
   name=$(echo ${response[@]} | jq '.results[0].name' | sed 's/"//g')
   echo ${path}/${name}
   jfrog rt dl gradle-release-local/${path}/${name} ./war/webservice.war --server-id=${SERVER_ID}  --flat=true --build-name=${gb_name} --build-number=${gb_no}
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


