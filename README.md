# Node Runner

## Description

The purpose of this repository is to provide the means of running a node within docker.

This readme was written primarily for Ubuntu.

## Instructions

### The `nr` Tool

The `nr` tool provides a few easy to use commands to help with managing your nodes. You can use the tool with this format:

```bash
nr <COMMAND>
```

Possible commands to run in conjunction with `nr`:
* `-k | --check [OPTIONAL: brand name]`   - Verify necessary files exist and configuration is setup properly, or specific to the brand specified
* `-n | --clean [OPTIONAL: brand name]`   - Delete all existing config files for a fresh start, or specific to the brand specified
* `-c | --config`                         - Prompt the user for various settings required to run nodes and save them for future use
* `-h | --help [OPTIONAL: command]`       - Prints out a helpful message about the tool and it's possible commands, or specific to the command specified
* `-i | --install`                        - Install Docker and Docker Compose if they are not already installed
* `-s | --start [OPTIONAL: brand name]`   - Start the nodes, or specific to the brand specified
* `-p | --stop [OPTIONAL: brand name]`    - Stop the nodes, or specific to the brand specified

### Installing Prerequisites

Use the `nr --install` command to install Docker and Docker-Compose. Upon a successful install you will need to either logout, then back in, or reboot your machine in order to utilize Docker.

### Configuration

Use the `nr --config` command to step through the prompts to create your node settings:

* `Brand of Nodes`  - Select the brand of nodes you want to run.
* `Node Name`       - Any arbitrary name used to identify a node. This is combined with the current datetime so that if you have multiple nodes running they will each have a unique name.
* `Username`        - Email address for the brand associated with the nodes.
* `Password`        - Password for the brand associated with the nodes.
* `Number of Nodes` - The number of nodes you want to run.

After supplying these values you will not need to do so again, so each subsequent startup will use the provided settings.

### Running Your Nodes

You can use the `nr --start` command to begin running your nodes.

> [!NOTE]
> You will need to use the `nr --install` command before you will be able to run your nodes.

Check that the nodes are running correctly. See [Verify that the Nodes are Running Correctly](#verify-that-the-nodes-are-running-correctly).

### Stopping Your Nodes

Use the `nr --stop` command to shutdown your nodes.

> [!WARNING]
> This will prevent them from restarting automatically on machine reboot. If you stop your nodes and don't start them again, they will NOT start automatically upon reboot.

## Auto start on reboot

After starting your nodes, if you do not intentionally stop them manually, they will automatically restart without requiring user intervention.

## Verify that the Nodes are Running Correctly

Check that the docker images are running correctly by running: `docker ps`

If all of your nodes are restarting over and over again, run this command to see what's going on:

```Bash
docker-compose logs --tail=0 --follow
```

Next log into your Nerd brand and check the active nodes count.

[Nerd United](https://app.nerdunited.com/dashboard/nodes)

If only only a few are constantly restarting, they may fix themselves but if they don't within a minute, blow the broken ones away and run the `nr --start` command again and it will leave healthy running nodes alone while starting up enough to replace the ones you destroyed. You may have to continue this process a few times until you reach the number of healthy nodes you need.
