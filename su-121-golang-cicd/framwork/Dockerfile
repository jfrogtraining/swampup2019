#FROM jfrog.local:5000/golang:1.11.2-alpine
FROM jfrog.local:5000/golang:1.12-alpine
ENV PORT 8080
ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on

# Install dependencies
RUN apk update && apk add --update gcc git musl-dev curl bash

# Notice the backslash in \$latest, ref: https://github.com/jfrog/jfrog-cli-go/issues/96
RUN curl -Lo /usr/bin/jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-386/jfrog?bt_package=jfrog-cli-linux-386 \
   && chmod a+x /usr/bin/jfrog

#WORKDIR /src/jfrogsolutionci/containerize-go-microservice/
#COPY ./ /src/jfrogsolutionci/containerize-go-microservice/

#RUN cd /src/jfrogsolutionci/containerize-go-microservice/ && go install
#CMD ["/go/bin/containerize-go-microservice"]