# Node Runner

## Description

The purpose of this repository is to provide the means of running a node within docker.

This readme was written primarily for Ubuntu.

## Prerequisites

### Docker

If you do not already have docker installed, run these commands:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

Then logout for the permissions to take effect.

### docker-compose

`docker-compose` is more resource efficient than `docker compose`.

Run `sudo apt-get install docker-compose`.

### example docker-compose.override.yml

```yml
version: '3.4'
services:
  node-runner:
    env_file:
      - .env
      - .env.local
    deploy:
      replicas: 3
    build:
      args:
        - BINARY_FILE=hyper-v2.6.1-b_linux-arm64
```

## Instructions

> [!NOTE]
> Docker Compose provides a setting called `restart` that allows for automatic restart of containers that fail or exit for any reason including when the hosting machine reboots unexpectedly. This is set by default within this project's docker-compose.yml file. So you shouldn't need to do any form of custom auto/self start.

### The `nr` Tool

The `nr` tool provides a few easy to use commands to help with managing the running of nodes. You can use the tool by this format `nr <COMMAND>`
* `init`    - This command will install Docker and Docker Compose if they are not already installed, configure the node settings, and start the nodes.
* `config`  - This command will prompt you for various settings and save them for future use.
* `start`   - Starts up the nodes
* `stop`    - This one also starts up the nodes
* `help`    - Prints out a helpfull message about the tool and it's possible commands.

Run the script manually the first time to make sure that the `.env.local` file is created and populated correctly.

Run `bash <path_to_repo>/run_nodes.sh`

You will be prompted to enter 3 different values:

* `Node Name` - Any arbitrary name used to identify a node. This is combined with the current datetime so that if you have multiple nodes running they will each have a unique name.
* `Username` - Email address associated with the nodes.
* `Password` - Password for the brand associated with the nodes.

After supplying these three things you will not be prompted for them again and each subsequent time will simply start up using the previously provided credentials and settings.

Check that the nodes are running correctly. See [Verify that the Nodes are Running Correctly](#verify-that-the-nodes-are-running-correctly).

## Auto start on reboot

Making the nodes auto start on reboot allows you the flexibility to shutdown your machine and turn it back on later and it will automatically start up the nodes you were running before.

There are multiple ways to do so - two are described here.

### .bashrc

Add this to your `.bashrc` file: `bash <path_to_repo>/run_nodes.sh`

### Systemd

Run `sudo bash autostart-with-systemd.sh`

## Verify that the Nodes and Running Correctly

Check that the docker images are running correctly by running: `docker ps`

If they are restarting over and over again, run this command to see what's going on:

```Bash
docker-compose logs --tail=0 --follow
```

Next log into your Nerd brand and check the active nodes count.

[Nerd United](https://app.nerdunited.com/dashboard/nodes)
