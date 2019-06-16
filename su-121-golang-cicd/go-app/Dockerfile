FROM jfrog.local:5000/golang:1.12-alpine

# ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on
ARG ARTIFACTORY_URL=
ARG ARTIFACTORY_ACCESS_TOKEN=
ARG ARTIFACTORY_USER=
ARG BUILD_NUMBER=
ARG BUILD_NAME=

RUN apk update && apk add --update git curl bash
RUN curl -Lo /usr/bin/jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-386/jfrog?bt_package=jfrog-cli-linux-386 \
	&& chmod a+x /usr/bin/jfrog \
	&& mkdir -p /go-swampup-service

RUN jfrog rt c swampup --url=$ARTIFACTORY_URL --access-token=$ARTIFACTORY_ACCESS_TOKEN --interactive=false

COPY src/main.go /go-swampup-service/
COPY src/go.mod /go-swampup-service/
WORKDIR /go-swampup-service
COPY go.yaml .jfrog/projects/


RUN jfrog rt go build . --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
RUN jfrog rt gp go-virtual v1.2.$BUILD_NUMBER --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER --server-id=swampup
RUN jfrog rt bce $BUILD_NAME v1.2.$BUILD_NUMBER
RUN jfrog rt bp $BUILD_NAME $BUILD_NUMBER --server-id=swampup


FROM jfrog.local:5000/docker-go-framework:latest

RUN mkdir -p /app
WORKDIR /app/

COPY --from=0  /go-swampup-service/go-swampup-service .

CMD ["/app/go-swampup-service"]
