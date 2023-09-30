# Node Runner

### Description
The purpose of this repository is to provide the means of running a node within docker.

### Instructions:
There is a bash script called run_nodes.sh that you can add to the very end of your .bashrc file for your user like so:

`bash <path_to_repo>/run_nodes.sh`

Adding the preceding line of code allows you the flexibility to shutdown your machine and turn it back on later and it will automatically start up the nodes you were running before.

Once you have added this line to you .bashrc file you can either reboot your system or manually run the bash script by running the following code:

`bash <path_to_repo>/run_nodes.sh`

You will be prompted 3 different things:
* Node Name
* Username
* Password

After supplying these three things you will not be prompted for them again and each subsequent time will simply start up using the previously provided credentials and settings.