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

## Instructions

Run the script manually the first time to make sure that the `.env.local` files is created and populated correctly.

Run `bash <path_to_repo>/run_nodes.sh`

You will be prompted 3 different things:

* Node Name
* Username
* Password

After supplying these three things you will not be prompted for them again and each subsequent time will simply start up using the previously provided credentials and settings.

Check that the nodes are running correctly.  See [Verify that the Nodes are Running Correctly](#verify-that-the-nodes-are-running-correctly).

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

Example: https://app.nerdunited.com/dashboard/nodes