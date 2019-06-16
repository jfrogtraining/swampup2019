FROM jfrog.local:5000/alpine:latest


# Install dependencies
RUN apk update && apk add --update gcc git musl-dev curl bash

# Notice the backslash in \$latest, ref: https://github.com/jfrog/jfrog-cli-go/issues/96
RUN curl -Lo /usr/bin/jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-386/jfrog?bt_package=jfrog-cli-linux-386 \
   && chmod a+x /usr/bin/jfrog


RUN mkdir -p /tools/statusok


WORKDIR /tools/statusok
COPY ./statusok  /tools/statusok/statusok
COPY ./config.json /tools/statusok/config.json

CMD ["/tools/statusok/statusok"]
