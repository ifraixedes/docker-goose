FROM golang:1.6
MAINTAINER ivan@fraixed.es

RUN go get bitbucket.org/liamstask/goose/cmd/goose && mkdir /db
WORKDIR /

VOLUME ["/db"]
