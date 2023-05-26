#!/bin/bash


# Install Golang

echo "Qaysi Go versiyasini o'rnatishni hohlaysiz y-> lts? (y/n):"
read install_go_lts

if [ "$install_go_lts" = "y" ]; then
    curl -fsSL https://dl.google.com/go/go1.20.3.linux-amd64.tar.gz -o go.tar.gz
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
else
    sudo apt-get update
    sudo apt-get install -y golang
fi


# Install Nodejs
echo "Qaysi Node.js versiyasini o'rnatishni hohlaysiz? (y/n):"
read install_nodejs_lts

if [ "$install_nodejs_lts" = "y" ]; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    sudo apt-get update
    sudo apt-get install -y nodejs
fi



# Install ngnix

sudo apt-get install -y nginx

echo "Sayt nomini kiriting (masalan, example.com):"
read domain_name

sudo bash -c "cat > /etc/nginx/sites-available/$domain_name << EOF
server {
        listen 80;
        listen [::]:80;

        root /var/www/html/$domain_name;
        index index.html index.htm index.nginx-debian.html;

        server_name $domain_name www.$domain_name;

        location / {
                try_files \$uri \$uri/ =404;
        }
}
EOF"


sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/


echo "Konfiguratsiya faylida o'zgartirishlar kiritishni xohlaysizmi? (ha/yuq):"
read config_changes

if [ "$config_changes" == "ha" ]
then
    sudo nano /etc/nginx/sites-available/$domain_name
fi
sudo nginx -t && sudo systemctl reload nginx



# Docker install
echo "Qaysi Docker versiyasini o'rnatishni hohlaysiz? (y/n):"
read install_docker_lts

if [ "$install_docker_lts" = "y" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
else
    sudo apt-get update
    sudo apt-get install -y docker.io
fi

sudo tee /etc/docker/daemon.json <<EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    }
}
EOF

sudo systemctl restart docker


# Check versions
go_version=$(go version)
node_version=$(node -v)
nginx_version=$(nginx -v 2>&1)
docker_version=$(docker -v)

echo "Go versiyasi: $go_version"
echo "Node.js versiyasi: $node_version"
echo "Nginx versiyasi: $nginx_version"
echo "Docker versiyasi: $docker_version"
