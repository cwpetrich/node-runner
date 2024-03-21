#!/bin/bash

# GLOBALS
SCRIPT=$(readlink -f "$0")
BASEDIRECTORY=$(dirname "$SCRIPT")
COMMAND_1=$1
COMMAND_2=$2
shift

requiredStringInput() {
    local message=$1
    local errorMessage=$2
    local result
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
    local result
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
    local result
    while true; do
        read -p "$message" result
        # Remove leading and trailing whitespace
        result=$(echo "$result" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        # If result is a number, break the loop
        if [[ "$result" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "$errorMessage"
        fi
    done
    echo "$result"
}

recommendedBinaryArch() {
    # Define the architectures for which the arm64 binary should be used
    local arm64s=("arm64" "aarch64")
    # Define the architectures for which the amd64 binary should be used
    local amd64s=("x86_64")
    # Detect the architecture of the host machine
    local host_arch=$(uname -m)
    # Define local variables
    local arch armIndex amdIndex

    # If the host machine's architecture is in the arm64s array, use the arm64 binary
    for armIndex in "${arm64s[@]}"; do
        [ "$armIndex" == "$host_arch" ] && arch="arm64" && break
    done
    # If the host machine's architecture is in the amd64s array and the arch variable is not set, use the amd64 binary
    if [ -z "$arch" ]; then
        for amdIndex in "${amd64s[@]}"; do
            [ "$amdIndex" == "$host_arch" ] && arch="amd64" && break
        done
    fi
    # If the arch variable is still not set, use the arm64 binary as a default
    if [ -z "$arch" ]; then
        arch="arm64"
    fi
    echo "$arch"
}

install() {
    local dockerInstalled=false
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh &&
            sudo sh get-docker.sh &&
            sudo usermod -aG docker $USER &&
            dockerInstalled=true
    else
        echo "Docker is already installed"
    fi

    if ! command -v docker-compose &>/dev/null; then
        sudo apt install docker-compose
    else
        echo "Docker Compose is already installed"
    fi

    if dockerInstalled; then
        echo "In order to utilize Docker a reboot is required"
        read -p "Reboot now? [Y/N]: " response
        if [[ $response =~ ^[Yy]$ ]]; then
            sudo shutdown -r now
        fi
    fi
}

help() {
    if [ -z "$COMMAND_2" ]; then
        echo "nr - a bash script for managing nodes"
        echo
        echo "Usage: nr <command>"
        echo
        echo "Available commands:"
        echo "  check   - Perform a file and config inspection"
        echo "  clean   - Clear all existing configurations"
        echo "  config  - Configure the node settings"
        echo "  help    - Display this help message"
        echo "  install - Install the required dependencies"
        echo "  start   - Start the nodes"
        echo "  stop    - Stop the nodes"
        echo
        echo "For more information on a specific command, use 'nr help <command>'"
    else
        case "$COMMAND_2" in
        check)
            echo "check - Perform a file and config inspection"
            echo
            echo "Usage: nr check"
            echo
            echo "This command will check if the required files and configurations are present."
            ;;
        clean)
            echo "clean - Clear all existing configurations"
            echo
            echo "Usage: nr clean"
            echo
            echo "This command will remove the .env.local and docker-compose.override.yml files."
            ;;
        config)
            echo "config - Configure the node settings"
            echo
            echo "Usage: nr config"
            echo
            echo "This command will prompt you for various settings and save them for future use."
            ;;
        help)
            echo "help - Display this help message"
            echo
            echo "Usage: nr help [command]"
            echo
            echo "Without any arguments, 'help' displays a list of available commands."
            echo "With an argument, 'help' displays detailed information about that command."
            ;;
        install)
            echo "install - Install the required dependencies"
            echo
            echo "Usage: nr install"
            echo
            echo "This command will install Docker and Docker Compose if they are not already installed."
            ;;
        start)
            echo "start - Start the nodes"
            echo
            echo "Usage: nr start"
            echo
            echo "This command will start the nodes with the settings you've configured."
            ;;
        stop)
            echo "stop - Stop the nodes"
            echo
            echo "Usage: nr stop"
            echo
            echo "This command will stop the nodes."
            ;;
        *)
            echo "Unknown command: $COMMAND_2"
            echo
            echo "Use 'nr help' for a list of available commands"
            ;;
        esac
    fi
}

config() {
    # Define the arch variable as a local variable
    local arch=$(recommendedBinaryArch)
    # Define the available brands
    local brands=("opus" "win" "element" "elevate" "galvan" "green" "grow" "nerd" "liberty" "smart" "switch")
    # Define the available versions
    local versions=("v2.6.1-b")
    # Define the local variables
    local brand version chain domain binary_url

    # If .env.local does not exist, copy .env into .env.local
    local envLocalFile=$BASEDIRECTORY/.env.local
    if ! [ -f $envLocalFile ]; then
        cp $BASEDIRECTORY/.env $BASEDIRECTORY/.env.local
    fi
    # Prompt the user for node name, username/email, and password, and update these values in .env.local
    local node_name=$(requiredStringInput "Node Name: " "Node Name cannot be empty or whitespace. Please try again.")
    local node_username=$(requiredStringInput "Username/Email: " "Username/Email cannot be empty or whitespace. Please try again.")
    local node_password=$(requiredHiddenInput "Password: " "Password cannot be empty or whitespace. Please try again.")
    echo
    sed -i "s|\(NODE_NAME=\).*|\1${node_name}|" $envLocalFile
    sed -i "s|\(NODE_USERNAME=\).*|\1${node_username}|" $envLocalFile
    sed -i "s|\(NODE_PASSWORD=\).*|\1${node_password}|" $envLocalFile

    # If docker-compose.override.yml does not exist, copy docker-compose.yml into docker-compose.override.yml and add update these values in it
    local composeOverrideFile=$BASEDIRECTORY/docker-compose.override.yml
    if ! [ -f $composeOverrideFile ]; then
        cp $BASEDIRECTORY/docker-compose.yml $composeOverrideFile
    fi

    if ! grep -Eq "\.env\.local" $composeOverrideFile; then
        sed -i 's|\(.*\)\(- \.env$\)|\1\2\n\1- \.env\.local|' $composeOverrideFile
    fi

    # Prompt the user for the number of nodes
    read -p "Number of Nodes: " node_count
    sed -i "s|\(replicas: \)[0-9]*|\1$node_count|" $composeOverrideFile

    # Prompt the user to choose a brand
    echo "Choose a Brand: "
    select brand in "${brands[@]}"; do
        case $brand in
        opus) break ;;
        win) break ;;
        element) break ;;
        elevate) break ;;
        galvan) break ;;
        green) break ;;
        grow) break ;;
        nerd) break ;;
        liberty) break ;;
        smart) break ;;
        switch) break ;;
        *) echo "Invalid option" ;;
        esac
    done

    sed -i "s|\(NODE_BRAND=\).*|\1${brand}|" $envLocalFile

    # Prompt the user to choose a version
    echo "Choose a Version: "
    select version in "${versions[@]}"; do
        case $version in
        v2.6.1-b) break ;;
        *) echo "Invalid option" ;;
        esac
    done

    echo "TEST BEFORE"

    case $brand in
    blockade)
        chain="opus"
        domain="blockchainandnodes.io"
        ;;
    connectunited)
        chain="win"
        domain="connectunited.com"
        ;;
    element)
        chain="element"
        domain="elementunited.com"
        ;;
    elevate)
        chain="elevate"
        domain="elevateunited.com"
        ;;
    galvan)
        chain="galvan"
        domain="galvan.health"
        ;;
    green)
        chain="green"
        domain="setpowerfree.com"
        ;;
    grow)
        chain="grow"
        domain="growblockchain.net"
        ;;
    nerd)
        chain="hyper"
        domain="nerdunited.com"
        ;;
    liberty)
        chain="liberty"
        domain="libertyblockchain.com"
        ;;
    smart)
        chain="smart"
        domain="smartbuilt.io"
        ;;
    switch)
        chain="switch"
        domain="switchrewardcard.com"
        ;;
    *)
        echo "Invalid Brand Option"
        ;;
    esac

    binary_url=https://download.${domain}/node-binaries/${version}/${chain}-${version}_linux-${arch}
    sed -i "s|\(BINARY_URL=\).*|\1${binary_url}|" $envLocalFile
}

start() {
    check &&
        docker-compose \
            -f $BASEDIRECTORY/docker-compose.yml \
            -f $BASEDIRECTORY/docker-compose.override.yml \
            up -d --build
}

stop() {
    docker-compose \
        -f $BASEDIRECTORY/docker-compose.yml \
        -f $BASEDIRECTORY/docker-compose.override.yml \
        down
}

clean() {
    rm $BASEDIRECTORY/docker-compose.override.yml
    rm $BASEDIRECTORY/.env.local
}

check() {
    if ! [ -f $BASEDIRECTORY/docker-compose.override.yml ]; then
        echo "ERR: Missing the docker-compose.override.yml file."
        echo "FIX: Run the \"nr config\" command"
        exit 1
    fi

    if ! [ -f $BASEDIRECTORY/.env.local ]; then
        echo "ERR: Missing the .env.local file."
        echo "FIX: Run the \"nr config\" command"
        exit 1
    fi

    if ! [ -f $BASEDIRECTORY/.env ]; then
        echo "ERR: Missing the .env file."
        echo "FIX: ONE of the following:"
        echo " * Download the project again. AKA start over."
        echo " * Use Git to revert to what is on origin/master."
        echo " * Recreate or otherwise copy the .env file back into the base directory of this project: https://github.com/cwpetrich/node-runner/blob/master/.env"
        exit 1
    fi

    if ! [ -f $BASEDIRECTORY/docker-compose.yml ]; then
        echo "ERR: Missing the docker-compose.yml file."
        echo "FIX: ONE of the following:"
        echo " * Download the project again. AKA start over."
        echo " * Use Git to revert to what is on origin/master."
        echo " * Recreate or otherwise copy the docker-compose.yml file back into the base directory of this project: https://github.com/cwpetrich/node-runner/blob/master/docker-compose.yml"
        exit 1
    fi

    if ! [ -f $BASEDIRECTORY/node-runner/Dockerfile ]; then
        echo "ERR: Missing the ./node-runner/Dockerfile file."
        echo "FIX: ONE of the following:"
        echo " * Download the project again. AKA start over."
        echo " * Use Git to revert to what is on origin/master."
        echo " * Recreate or otherwise copy the docker-compose.yml file back into the base directory of this project: https://github.com/cwpetrich/node-runner/blob/master/node-runner/Dockerfile"
        exit 1
    fi

    if ! [ -f $BASEDIRECTORY/node-runner/launch.sh ]; then
        echo "ERR: Missing the ./node-runner/launch.sh file."
        echo "FIX: ONE of the following:"
        echo " * Download the project again. AKA start over."
        echo " * Use Git to revert to what is on origin/master."
        echo " * Recreate or otherwise copy the docker-compose.yml file back into the base directory of this project: https://github.com/cwpetrich/node-runner/blob/master/node-runner/launch.sh"
        exit 1
    fi

    # See if the architecture for the url used to download the binary in the .env.local file matches what is suggested
    local arch=$(recommendedBinaryArch)
    if ! grep -Eq "$arch" $BASEDIRECTORY/.env.local; then
        echo "WRN: The architecture for the binary URL in the .env.local file does not match the recommended architecture."
        echo "CURRENT: $(grep -E "BINARY_URL=.*linux-" $BASEDIRECTORY/.env.local | sed -e 's/.*linux-//' -e 's/".*//')"
        echo "RECOMMENDED: $arch"
        echo "FIX: Run the \"nr config\" command"
    fi

    # See if Docker and Docker-Compose are installed
    if ! command -v docker &>/dev/null; then
        echo "ERR: Docker is not installed"
        echo "FIX: Run the \"nr install\" command"
        exit 1
    fi

    if ! command -v docker-compose &>/dev/null; then
        echo "ERR: Docker Compose is not installed"
        echo "FIX: Run the \"nr install\" command"
        exit 1
    fi

    echo "All Checks Passed!"
}

case $COMMAND_1 in
check)
    check
    ;;
clean)
    clean
    ;;
config)
    config
    ;;
help)
    help
    ;;
install)
    install
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
*)
    echo "Unknown command: $COMMAND_1"
    echo "Use 'nr help' for a list of available commands"
    ;;
esac
