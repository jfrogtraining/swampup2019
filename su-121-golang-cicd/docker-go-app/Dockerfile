FROM jfrog.local:5000/docker-go-framework:latest
MAINTAINER Elio Marcolino eliom@jfrog.com

RUN mkdir -p /app
WORKDIR /app/

COPY go-swampup-service .
RUN chmod +x go-swampup-service

CMD ["/app/go-swampup-service"]
