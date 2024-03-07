FROM ubuntu:latest

RUN apt update

COPY ./hyper-v2.6.1-b_linux-arm64  /usr/local/bin/hyper
COPY ./launch.sh /root

WORKDIR /root

ENTRYPOINT ["bash", "launch.sh"]
