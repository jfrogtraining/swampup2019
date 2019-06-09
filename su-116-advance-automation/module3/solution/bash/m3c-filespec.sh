# Exercise 3c - Filespec upload with properties
uploadFileSpec () {
  echo "Uploading binaries to Artifactory"
  jfrog rt u --spec $1 --server-id ${SERVER_ID}
}