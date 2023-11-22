#!/bin/bash
# Allows Ansible not to display messages related to adding ssh accounts

# Define an array of target hosts
source .env
target_hosts=($IP_CP $IP_W1 $IP_W2)

# Loop through the target hosts and run ssh-keyscan for each
for host in "${target_hosts[@]}"; do
    ssh-keyscan -t ed25519 "$host" >> $HOME/.ssh/known_hosts
    echo "Host key for $host added to known_hosts file."
done