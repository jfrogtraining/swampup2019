#Exercise 3b - JFROG CLI Download
loginArt () {
   echo "Log into Artifactories"
   curl -fLs jfrog https://getcli.jfrog.io | sh
   jfrog <TBD> ${REMOTE_ART_ID} --url=${REMOTE_ARTFACTORY} --apikey=${REMOTE_ART_APIKEY}
   jfrog <TBD> ${SERVER_ID} --url=${ART_URL} --apikey=${USER_APIKEY}
   jfrog <TBD> show
}

# Download the required dependencies from remote artifactory instance (jfrogtraining)
# paths -
#    tomcat-local/org/apache/apache-tomcat/
#    tomcat-local/java/
#    generic-local/helm
# Similar to using third party binaries that are not available from remote repositories.
downloadDependencies () {
  echo "Fetch tomcat for the later docker framework build"
  jfrog <TBD> ${TOMCAT} ./tomcat/apache-tomcat-8.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=<TBD
  echo "Fetch java for the later docker framework build"
  jfrog <TBD> ${JDK} ./jdk/jdk-8-linux-x64.tar.gz --server-id ${REMOTE_ART_ID} --threads=5 --flat=true --props=<TBD>
  echo "Fetch Helm Client for later helm chart"
  jfrog <TBD> ${HELM} ./ --server-id ${REMOTE_ART_ID} --props=<TBD>
}

