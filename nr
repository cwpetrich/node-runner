#!/bin/bash

SCRIPT=$(readlink -f "$0")
BASEDIRECTORY=$(dirname "$SCRIPT")
NODE_BRANDS=("opus" "win" "element" "elevate" "galvan" "green" "grow" "nerd" "liberty" "smart" "switch")
NODE_VERSIONS=("v2.6.1-b")

requiredStringInput() {
    local result message=$1 errorMessage=$2
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
    local result message=$1 errorMessage=$2
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
    local result message=$1 errorMessage=$2
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

selectBrand() {
    local brand
    # Prompt the user to choose a brand
    echo "Choose a Brand: " >&2
    select brand in "${NODE_BRANDS[@]}"; do
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
        *) echo "Invalid option" && exit 1 ;;
        esac
    done
    echo "$brand"
}

getBrandDomain() {
    local brand domain
    if [ -z "$1" ]; then
        echo "Brand not provided" >&2
        exit 1
    fi
    brand=$1
    case $brand in
    blockade)
        domain="blockchainandnodes.io"
        ;;
    connectunited)
        domain="connectunited.com"
        ;;
    element)
        domain="elementunited.com"
        ;;
    elevate)
        domain="elevateunited.com"
        ;;
    galvan)
        domain="galvan.health"
        ;;
    green)
        domain="setpowerfree.com"
        ;;
    grow)
        domain="growblockchain.net"
        ;;
    nerd)
        domain="nerdunited.com"
        ;;
    liberty)
        domain="libertyblockchain.com"
        ;;
    smart)
        domain="smartbuilt.io"
        ;;
    switch)
        domain="switchrewardcard.com"
        ;;
    *)
        echo "Invalid Brand Option" >&2
        exit 1
        ;;
    esac
    echo "$domain"
}

getBrandChain() {
    local brand chain
    if [ -z "$1" ]; then
        echo "Brand not provided" >&2
        exit 1
    fi
    local brand=$1
    case $brand in
    blockade)
        chain="opus"
        ;;
    connectunited)
        chain="win"
        ;;
    element)
        chain="element"
        ;;
    elevate)
        chain="elevate"
        ;;
    galvan)
        chain="galvan"
        ;;
    green)
        chain="green"
        ;;
    grow)
        chain="grow"
        ;;
    nerd)
        chain="hyper"
        ;;
    liberty)
        chain="liberty"
        ;;
    smart)
        chain="smart"
        ;;
    switch)
        chain="switch"
        ;;
    *)
        echo "Invalid Brand Option" >&2
        exit 1
        ;;
    esac
    echo "$chain"
}

selectVersion() {
    local version
    # Prompt the user to choose a version and store it in the configFile
    echo "Choose a Version: " >&2
    select version in "${NODE_VERSIONS[@]}"; do
        case $version in
        v2.6.1-b) break ;;
        *) echo "Invalid option" ;;
        esac
    done
    echo "$version"
}

install() {
    local response dockerInstalled=false
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh &&
            sudo sh get-docker.sh &&
            sudo usermod -aG docker $USER &&
            dockerInstalled=true
    else
        echo "Docker is already installed" >&2
    fi

    if ! command -v docker-compose &>/dev/null; then
        sudo apt install docker-compose
    else
        echo "Docker Compose is already installed" >&2
    fi

    if $dockerInstalled; then
        echo "In order to utilize Docker a reboot is required" >&2
        read -p "Reboot now? [Y/N]: " response
        if [[ $response =~ ^[Yy]$ ]]; then
            sudo shutdown -r now
        fi
    fi
}

help() {
    if [ -z "$1" ]; then
        echo "nr - a bash script for managing nodes"
        echo
        echo "Usage: nr <command>"
        echo
        echo "Available commands:"
        echo "  -c | --check   - Perform a file and config inspection"
        echo "  -n | --clean   - Clear all existing configurations"
        echo "  -c | --config  - Configure the node settings"
        echo "  -h | --help    - Display this help message"
        echo "  -i | --install - Install the required dependencies"
        echo "  -s | --start   - Start the nodes"
        echo "  -p | --stop    - Stop the nodes"
        echo
        echo "For more information on a specific command, use 'nr -h | --help <command>'"
    else
        case "$1" in
        -h | --help)
            echo "check - Perform a file and config inspection"
            echo
            echo "Usage: nr -k | --check [OPTIONAL: brand name]"
            echo
            echo "This command will check if the required files and configurations are present."
            ;;
        -n | --clean)
            echo "clean - Clear all existing configurations"
            echo
            echo "Usage: nr -n | --clean [OPTIONAL: brand name]"
            echo
            echo "This command will remove the docker-compose.override.yml file."
            ;;
        -c | --config)
            echo "config - Configure the node settings"
            echo
            echo "Usage: nr -c | --config"
            echo
            echo "This command will prompt you for various settings and save them for future use."
            ;;
        -h | --help)
            echo "help - Display this help message"
            echo
            echo "Usage: nr -h | --help [OPTIONAL: command]"
            echo
            echo "Without any arguments, 'help' displays a list of available commands."
            echo "With an argument, 'help' displays detailed information about that command."
            ;;
        -i | --install)
            echo "install - Install the required dependencies"
            echo
            echo "Usage: nr -i | --install"
            echo
            echo "This command will install Docker and Docker Compose if they are not already installed."
            ;;
        -s | --start)
            echo "start - Start the nodes"
            echo
            echo "Usage: nr -s | --start [OPTIONAL: brand name]"
            echo
            echo "This command will start the nodes with the settings you've configured."
            ;;
        -p | --stop)
            echo "stop - Stop the nodes"
            echo
            echo "Usage: nr -p | --stop [OPTIONAL: brand name]"
            echo
            echo "This command will stop the nodes."
            ;;
        *)
            echo "Unknown command: $1"
            echo
            echo "Use 'nr -h | --help' for a list of available commands"
            ;;
        esac
    fi
}

config() {
    # Define the local variables
    local arch brand version chain domain binary_url override node_name username password replicas
    # Define the arch variable as a local variable
    arch=$(recommendedBinaryArch)

    # Prompt the user to choose a brand
    brand=$(selectBrand)
    domain=$(getBrandDomain $brand)
    chain=$(getBrandChain $brand)

    # Define the configFile variable as a local variable base on the brand selected
    override=$BASEDIRECTORY/config/$brand/docker-compose.override.yml

    # If docker-compose.override.yml does not exist, copy docker-compose.yml into docker-compose.override.yml
    if ! [ -d $BASEDIRECTORY/config/$brand ]; then
        mkdir -p $BASEDIRECTORY/config/$brand
    fi
    if ! [ -f $override ]; then
        cp $BASEDIRECTORY/docker-compose.yml $override
    fi

    # Store the brand, chain, domain, and arch in the configFile
    sed -i "s|\(NODE_BRAND=\).*|\1${brand}|" $override
    sed -i "s|\(NODE_CHAIN=\).*|\1${chain}|" $override
    sed -i "s|\(NODE_DOMAIN=\).*|\1${domain}|" $override
    sed -i "s|\(HOST_MACHINE_ARCH=\).*|\1${arch}|" $override

    # Prompt the user for node name and store it in the configFile
    node_name=$(requiredStringInput "Node Name: " "Node Name cannot be empty or whitespace. Please try again.")
    sed -i "s|\(NODE_NAME=\).*|\1${node_name}|" $override

    # Prompt the user for username and store it in the configFile
    username=$(requiredStringInput "Username/Email: " "Username/Email cannot be empty or whitespace. Please try again.")
    sed -i "s|\(NODE_USERNAME=\).*|\1${username}|" $override

    # Prompt the user for password and store it in the configFile
    password=$(requiredHiddenInput "Password: " "Password cannot be empty or whitespace. Please try again.")
    # Add a newline after the hidden input to move the cursor to the next line
    echo
    sed -i "s|\(NODE_PASSWORD=\).*|\1${password}|" $override

    # Prompt the user for the number of nodes and store it in the configFile
    replicas=$(requiredNumericInput "Number of Nodes: " "Number of Nodes must be a number. Please try again.")
    sed -i "s|\(replicas: \)[0-9]*|\1$replicas|" $override

    # Prompt the user to choose a version and store it in the configFile
    version=$(selectVersion)
    sed -i "s|\(NODE_VERSION=\).*|\1${version}|" $override

    # Use the domain, version, chain, and arch to create the binary_url and store it in the configFile
    binary_url=https://download.${domain}/node-binaries/${version}/${chain}-${version}_linux-${arch}
    sed -i "s|\(NODE_BINARY_URL=\).*|\1${binary_url}|" $override
}

start() {
    local brand="${1:-all}"
    if [ "$brand" == "all" ]; then
        for brand in "${NODE_BRANDS[@]}"; do
            if [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
                echo "Starting $brand nodes..."
                check $brand &&
                    docker-compose \
                        -f $BASEDIRECTORY/docker-compose.yml \
                        -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml \
                        up -d --build
            else
                echo "Skipping $brand nodes due to no configuration file."
            fi
        done
    else
        echo "Starting $brand nodes..."
        check $brand &&
            docker-compose \
                -f $BASEDIRECTORY/docker-compose.yml \
                -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml \
                up -d --build
    fi
}

stop() {
    local brand="${1:-all}"
    if [ "$brand" == "all" ]; then
        for brand in "${NODE_BRANDS[@]}"; do
            if [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
                docker-compose \
                    -f $BASEDIRECTORY/docker-compose.yml \
                    -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml \
                    down
            fi
        done
    else
        if [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
            docker-compose \
                -f $BASEDIRECTORY/docker-compose.yml \
                -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml \
                down
        fi
    fi
}

clean() {
    local brand="${1:-all}"
    if [ "$brand" == "all" ]; then
        for brand in "${NODE_BRANDS[@]}"; do
            if [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
                rm $BASEDIRECTORY/config/$brand/docker-compose.override.yml
            fi
        done
    else
        if [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
            rm $BASEDIRECTORY/config/$brand/docker-compose.override.yml
        fi
    fi
}

check() {
    local brand="${1:-}"
    if [ -n "$brand" ]; then
        if ! [[ " ${NODE_BRANDS[@]} " =~ " ${brand} " ]]; then
            echo "ERR: Invalid brand: $brand"
            echo "FIX: Use one of the following brands: ${NODE_BRANDS[@]}"
            exit 1
        fi

        if ! [ -f $BASEDIRECTORY/config/$brand/docker-compose.override.yml ]; then
            echo "ERR: Missing the docker-compose.override.yml file for $brand."
            echo "FIX: Run the \"nr -c $brand\" command"
        fi

        # See if the architecture for the url used to download the binary in the override file matches what is suggested
        local arch=$(recommendedBinaryArch)
        if ! grep -Eq "$arch" $BASEDIRECTORY/config/$brand/docker-compose.override.yml; then
            echo "WRN: The architecture for the binary URL in the docker-compose.override.yml file for $brand does not match the recommended architecture."
            echo "CURRENT: $(grep -E "NODE_BINARY_URL=.*linux-" $BASEDIRECTORY/config/$brand/docker-compose.override.yml | sed -e 's/.*linux-//' -e 's/".*//')"
            echo "RECOMMENDED: $arch"
            echo "FIX: Run the \"nr -c $brand\" command"
        fi
    else
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

        for brand in "${NODE_BRANDS[@]}"; do
            check $brand
        done
    fi
}

while true; do
    case "$1" in
    -h | --help)
        help "${2:-}"
        break
        ;;
    -i | --install)
        install
        break
        ;;
    -n | --clean)
        clean "${2:-}"
        break
        ;;
    -c | --config)
        config
        break
        ;;
    -s | --start)
        start "${2:-}"
        break
        ;;
    -p | --stop)
        stop "${2:-}"
        break
        ;;
    -k | --check)
        check "${2:-}"
        break
        ;;
    *)
        help
        break
        ;;
    esac
done
