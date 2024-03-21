node_dir=/usr/local/bin
node_exec=$node_dir/$NODE_BRAND
date_stamp=$(date +%s)
curl "$BINARY_URL?$date_stamp" -o $node_exec
chmod +x $node_exec

$node_exec reset
$node_exec config <<EOL
$NODE_USERNAME
$NODE_PASSWORD
"$NODE_NAME-$date_stamp"
EOL
$node_exec
