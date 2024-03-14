FROM ubuntu:latest

ARG BINARY_FILE=hyper-v2.6.1-b_linux-arm64

RUN apt update && apt install -y dos2unix

COPY ./${BINARY_FILE}  /usr/local/bin/hyper
COPY ./launch.sh /root

RUN dos2unix /root/launch.sh

RUN chmod +x /usr/local/bin/hyper

WORKDIR /root

ENTRYPOINT ["bash", "launch.sh"]
