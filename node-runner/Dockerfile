FROM ubuntu:latest

RUN apt update

COPY ./hyper /usr/local/bin
COPY ./launch.sh /root

WORKDIR /root

ENTRYPOINT ["bash", "launch.sh"]
