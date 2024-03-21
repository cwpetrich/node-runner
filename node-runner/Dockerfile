FROM ubuntu:latest

ARG BINARY_URL
ARG NODE_BRAND
ARG NODE_NAME
ARG NODE_USERNAME
ARG NODE_PASSWORD

ENV BINARY=$NODE_BRAND

RUN apt update && apt install -y curl

WORKDIR /usr/local/bin

RUN curl -f "$BINARY_URL?$(date +%s)" -o $BINARY
RUN chmod +x $BINARY
RUN $BINARY reset
RUN $BINARY config <<EOL
$NODE_USERNAME
$NODE_PASSWORD
"$NODE_NAME-$(date +%s)"
EOL

ENTRYPOINT /usr/local/bin/$BINARY
