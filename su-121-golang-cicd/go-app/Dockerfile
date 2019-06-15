FROM jfrog.local:5000/golang:1.12-alpine
ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on

RUN jfrog rt go-config --global
RUN mkdir -p /go-swampup-service
COPY src/main.go /go-swampup-service/
WORKDIR /go-swampup-service
RUN go build -o go-swampup-service main.go
FROM jfrog.local:5000/containerize-go-microservice:latest
WORKDIR /root/
COPY --from=0  /go-swampup-service/go-swampup-service .
CMD ["/root/go-swampup-service"]
