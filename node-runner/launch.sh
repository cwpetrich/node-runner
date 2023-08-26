name=$NODE_NAME
brand=$NODE_BRAND
domain=$NODE_DOMAIN
environment=$NODE_ENVIRONMENT
architecture=$NODE_ARCHITECTURE
node_dir="/usr/local/bin"
node_exec="$node_dir/hyper"
date_stamp=$(date +%s)
download_url="https://${domain}/node-binaries/${brand}/${environment}/${brand}_linux-${architecture}?${date_stamp}"
#wget $download_url --output-document "${node_dir}/wget_test/${brand}" --quiet
#curl $download_url -o "${node_dir}/curl_test/${brand}"
#chmod +x $node_exec

$node_exec reset
$node_exec config <<EOL
$NODE_USERNAME
$NODE_PASSWORD
"${name}_${date_stamp}"
EOL
$node_exec
