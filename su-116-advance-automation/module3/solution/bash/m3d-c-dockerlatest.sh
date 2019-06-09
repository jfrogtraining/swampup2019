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
