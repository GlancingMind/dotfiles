#FROM alpine:3.12
FROM ubuntu:bionic

WORKDIR /app

RUN apt-get update
RUN apt-get install unzip
ADD https://github.com/jaredly/reason-language-server/releases/download/1.7.10/rls-linux.zip ./
RUN unzip rls-linux.zip
RUN rm -r rls-linux.zip

ENTRYPOINT [ "rls-linux/reason-language-server", "--stdio" ]
