#!/bin/bash

# Tell packer to wait 30 seconds so we know the instance is ready
sleep 30

# Update the packages
sudo yum update -y

# Install & setup nginx
sudo amazon-linux-extras install nginx1 -y
sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
sudo systemctl start nginx