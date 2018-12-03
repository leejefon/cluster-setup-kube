source ./env.sh

sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo mkdir -p /etc/nginx/tcpconf.d

# Might need to do manually
sudo echo "\n\ninclude /etc/nginx/tcpconf.d/*;" >>  /etc/nginx/nginx.conf

cat << EOF | sudo tee /etc/nginx/tcpconf.d/kubernetes.conf
stream {
    upstream kubernetes {
        server $CONTROLLER0_IP:6443;
        server $CONTROLLER1_IP:6443;
    }

    server {
        listen 6443;
        listen 443;
        proxy_pass kubernetes;
    }
}
EOF

sudo nginx -s reload
