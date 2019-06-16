FROM jfrog.local:5000/alpine:3.9

# Install dependencies
RUN apk update && apk add --update gcc git musl-dev curl bash

RUN mkdir -p /tools/statusok

WORKDIR /tools/statusok
COPY ./statusok  /tools/statusok/statusok
COPY ./config.json /tools/statusok/config.json

CMD ["/tools/statusok/statusok"]
