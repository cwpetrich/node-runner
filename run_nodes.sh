file=~/node-runner/.env.local
if ! [ -f $file ]; then
    cp ~/node-runner/.env ~/node-runner/.env.local
    read -p "Node Name: " node_name
    read -p "Username: " node_username
    read -sp "Password: " node_password
    sed -i "s/<nodename>/${node_name}/" $file
    sed -i "s/<username>/${node_username}/" $file
    sed -i "s/<password>/${node_password}/" $file
fi

cd ~/node-runner
docker-compose up -d --build