FROM jfrog.local:5000/golang:1.12-alpine
ENV GOPROXY=https://gocenter.io
ENV GO111MODULE=on

RUN mkdir -p /go-swampup-service

COPY src/main.go /go-swampup-service/
WORKDIR /go-swampup-service

# RUN go mod download
RUN go build -o go-swampup-service main.go

FROM jfrog.local:5000/docker-go-framework:latest

RUN mkdir -p /app
WORKDIR /app/

COPY --from=0  /go-swampup-service/go-swampup-service .

CMD ["/app/go-swampup-service"]
