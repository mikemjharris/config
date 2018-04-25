#!/bin/bash

### Script to setup aws config cause the dns changes every time it restarts.
### You need a template setup in ~/.ssh/config with this sort of config: the script will replace in the new dns
#
### DEV CONFIG START
#  Host mike-dev
#    ForwardAgent yes
#    HostName placeholder-name-that-gets-replaced 
#    IdentityFile ~/.ssh/name-of-pem.pem
#    User ubuntu
#    StrictHostKeyChecking no
### DEV CONFIG END

echo 'Getting aws dns'
AWS_DNS=$(aws ec2 describe-instances | jq .Reservations[0].Instances[0].PublicDnsName | sed -E 's/"//g')

echo $AWS_DNS
cat ~/.ssh/config | sed -n '/DEV CONFIG START/,$p' | sed -E 's/HostName [-.0-9A-z]+/HostName '"$AWS_DNS"'/' > /tmp/aws-dns

echo "Removing any existing config"
sed -i -e '/DEV CONFIG START/,/DEV CONFIG END/d' ~/.ssh/config

echo "Inserting new config"
cat /tmp/aws-dns >> ~/.ssh/config
