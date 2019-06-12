#!/usr/bin/env bash
set -o xtrace

usage() {
    echo "Deploy project to Production"
    echo "Usage: $1 artifactory address"
    echo "Usage: $2 docker repository name"
    exit 1
}

if [ -z "$1" ] || [ -z "$2"  ]; then
    usage
fi


SERVER=$1
REPOSITORY=$2

cat << EOF > /etc/docker/daemon.json
{
  "insecure-registries": ["http://${SERVER}:80"]
}
EOF

sudo service docker restart

echo "password" | docker login --username admin --password-stdin

docker stop docker-web-app  && docker rm $_
echo  rmi $(docker images --filter=reference=${SERVER}/${REPOSITORY}/web-app:latest)

docker stop docker-go-service  && docker rm $_
docker rmi $(docker images --filter=reference=${SERVER}/${REPOSITORY}/go-service:latest)

export GO_SERVICE=127.0.0.1

docker run -d --name docker-web-app -p 80:80 ${SERVER}/${REPOSITORY}/web-app:latest
docker run -d --name docker-go-service -p 3000:3000 ${SERVER}/${REPOSITORY}/go-service:latest


echo "Deploy Done"
