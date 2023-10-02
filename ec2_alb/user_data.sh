#!/bin/bash#

sudo apt update
sudo apt install -y nginx

ip_private=$(hostname -I | cut -d' ' -f1)

# Create a custom HTML file with the content including the private IP
echo "<html><body><h1>Hello $ip_private</h1></body></html>" > /var/www/html/index.html


# Start Nginx and enable it to start at boot
sudo systemctl start nginx
sudo systemctl enable nginx
