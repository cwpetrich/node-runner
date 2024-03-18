#!/bin/bash

# GLOBALS
SCRIPT=$(readlink -f "$0")
BASEDIRECTORY=$(dirname "$SCRIPT")

requiredStringInput() {
    local message=$1
    local errorMessage=$2
    while true; do
        read -p "$message" result
        # Remove leading and trailing whitespace
        result=$(echo "$result" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        # If result is not empty, break the loop
        if [[ -n "$result" ]]; then
            break
        else
            echo "$errorMessage"
        fi
    done
    echo "$result"
}

requiredHiddenInput() {
    local message=$1
    local errorMessage=$2
    while true; do
        read -sp "$message" result
        # Remove leading and trailing whitespace
        result=$(echo "$result" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        # If result is not empty, break the loop
        if [[ -n "$result" ]]; then
            break
        else
            echo "$errorMessage"
        fi
    done
    echo "$result"
}

requiredNumericInput() {
    local message=$1
    local errorMessage=$2
    while true; do
        read -p "$message" result
        # If result is a number, break the loop
        if [[ "$result" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "$errorMessage"
        fi
    done
    echo "$result"
}

install() {
    (curl -fsSL https://get.docker.com -o get-docker.sh) &&
        (sudo sh get-docker.sh) &&
        (sudo usermod -aG docker $USER) &&
        (sudo apt install docker-compose)
}

help() {
    if [ -z "$1" ]; then
        echo "nr - a bash script for managing nodes"
        echo
        echo "Usage: nr <command>"
        echo
        echo "Available commands:"
        echo "  init    - Install the required dependencies, configure the node settings, and start the nodes"
        echo "  config  - Configure the node settings"
        echo "  start   - Start the nodes"
        echo "  stop    - Stop the nodes"
        echo "  help    - Display this help message"
        echo
        echo "For more information on a specific command, use 'nr help <command>'"
    else
        case "$1" in
        init)
            echo "init - Install the required dependencies, configure the node settings, and start the nodes"
            echo "Usage: nr init"
            echo "This command will install Docker and Docker Compose if they are not already installed, configure the node settings, and start the nodes."
            ;;
        config)
            echo "config - Configure the node settings"
            echo "Usage: nr config"
            echo "This command will prompt you for various settings and save them for future use."
            ;;
        start)
            echo "start - Start the nodes"
            echo "Usage: nr start"
            echo "This command will start the nodes with the settings you've configured."
            ;;
        stop)
            echo "stop - Stop the nodes"
            echo "Usage: nr stop"
            echo "This command will stop the nodes."
            ;;
        help)
            echo "help - Display this help message"
            echo "Usage: nr help [command]"
            echo "Without any arguments, 'help' displays a list of available commands."
            echo "With an argument, 'help' displays detailed information about that command."
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use 'nr help' for a list of available commands"
            ;;
        esac
    fi
}

init() {
    install && config && start
}

config() {
    # Define the architectures for which the arm64 binary should be used
    arm64s=("arm64" "aarch64")
    # Define the architectures for which the amd64 binary should be used
    amd64s=("x86_64")
    # Detect the architecture of the host machine
    host_arch=$(uname -m)
    # If the host machine's architecture is in the arm64s array, use the arm64 binary
    for a in "${arm64s[@]}"; do
        [ "$a" == "$host_arch" ] && arch="arm64" && break
    done
    # If the host machine's architecture is in the amd64s array and the arch variable is not set, use the amd64 binary
    if [ -z "$arch" ]; then
        for a in "${amd64s[@]}"; do
            [ "$a" == "$host_arch" ] && arch="amd64" && break
        done
    fi
    # If the arch variable is still not set, use the arm64 binary as a default
    if [ -z "$arch" ]; then
        arch="arm64"
    fi

    # If .env.local does not exist, copy .env into .env.local
    envLocalFile=$BASEDIRECTORY/.env.local
    if ! [ -f $envLocalFile ]; then
        cp $BASEDIRECTORY/.env $BASEDIRECTORY/.env.local
    fi
    # Prompt the user for node name, username/email, and password, and update these values in .env.local
    node_name=$(requiredStringInput "Node Name: " "Node Name cannot be empty or whitespace. Please try again.")
    node_username=$(requiredStringInput "Username/Email: " "Username/Email cannot be empty or whitespace. Please try again.")
    node_password=$(requiredHiddenInput "Password: " "Password cannot be empty or whitespace. Please try again.")
    echo
    sed -i "s/\(NODE_NAME=\).*/\1${node_name}/" $envLocalFile
    sed -i "s/\(NODE_USERNAME=\).*/\1${node_username}/" $envLocalFile
    sed -i "s/\(NODE_PASSWORD=\).*/\1${node_password}/" $envLocalFile

    # If docker-compose.override.yml does not exist, copy docker-compose.yml into docker-compose.override.yml and add update these values in it
    composeOverrideFile=$BASEDIRECTORY/docker-compose.override.yml
    if ! [ -f $composeOverrideFile ]; then
        cp $BASEDIRECTORY/docker-compose.yml $composeOverrideFile
    fi

    if ! grep -Eq "\.env\.local" $composeOverrideFile; then
        sed -i 's/\(.*\)\(- \.env$\)/\1\2\n\1- \.env\.local/' $composeOverrideFile
    fi

    # Prompt the user for the number of nodes
    read -p "Number of Nodes: " node_count
    sed -i "s/\(replicas: \)[0-9]*/\1$node_count/" $composeOverrideFile

    # Define the available brands
    brands=("hyper")
    # Prompt the user to choose a brand
    echo "Choose a Brand: "
    select brand in "${brands[@]}"; do
        case $brand in
        hyper) break ;;
        *) echo "Invalid option" ;;
        esac
    done
    sed -i "s/\(BINARY_FILE=\).*/\1$brand-v2.6.1-b_linux-$arch/" $composeOverrideFile
}

start() {
    cd $BASEDIRECTORY
    docker-compose up -d --build
}

stop() {
    cd $BASEDIRECTORY
    docker-compose down
}

command=$1
shift

case $command in
init)
    init
    ;;
config)
    config
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
help)
    help
    ;;
*)
    echo "Unknown command: $command"
    echo "Use 'nr help' for a list of available commands"
    ;;
esac
