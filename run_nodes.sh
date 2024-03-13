#!/bin/bash

SCRIPT=$(readlink -f "$0") 
BASEDIRECTORY=$(dirname "$SCRIPT") 

file=$BASEDIRECTORY/.env.local 

if ! [ -f $file ]; then 
    cp $BASEDIRECTORY/.env $BASEDIRECTORY/.env.local 
    read -p "Node Name: " node_name 
    read -p "Username: " node_username 
    read -sp "Password: " node_password 
    sed -i "s/<nodename>/${node_name}/" $file 
    sed -i "s/<username>/${node_username}/" $file 
    sed -i "s/<password>/${node_password}/" $file 
fi 

cd $BASEDIRECTORY 
docker-compose up -d --build 