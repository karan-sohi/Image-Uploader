#!/bin/bash

# Packer needs to wait until the server is ready. 30 seconds seems safe.
sleep 30

# Install Mongodb
sudo mv /tmp/mongodb-org-4.4.repo /etc/yum.repos.d/mongodb-org-4.4.repo
sudo yum install -y mongodb-org
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
sudo systemctl start mongod
sudo systemctl enable mongod
