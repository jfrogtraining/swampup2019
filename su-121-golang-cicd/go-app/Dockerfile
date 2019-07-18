FROM jfrog.local:5000/docker-go-framework:latest

RUN mkdir -p /app
WORKDIR /app/

COPY go-swampup-service .

CMD ["/app/go-swampup-service"]
