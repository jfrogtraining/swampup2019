FROM jfrog.local:5000/golang:1.12-alpine
ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on

RUN mkdir src
COPY main.go src
RUN go env
#RUN go mod init go-swampup-service
RUN ls -al
RUN cd src && go build -v ./...

FROM jfrog.local:5000/alpine

COPY src/main .

