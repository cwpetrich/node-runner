FROM ubuntu:latest

RUN apt update && apt install -y dos2unix

COPY ./launch.sh /root

RUN dos2unix /root/launch.sh

WORKDIR /root

ENTRYPOINT ["bash", "launch.sh"]
