FROM jfrog.local:5000/golang:1.12-alpine
ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on

RUN cd go-swampup-service && go test ./...

FROM jfrog.local:5000/alpine

COPY go-swampup-service/main .

