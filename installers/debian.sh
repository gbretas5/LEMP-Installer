#!/bin/bash

echo -e "Starting Debian installer Script..."

MYSQL_ROOT_PASSWORD=$1

#updating packages
echo -e "Updating package lists.."
sudo apt-get -y update

#install Ngnix
echo -e "Installing Ngnix server..."
sudo apt-get -y install nginx

#install Mysql server
echo -e "Installing Mysql server..."
#set password from provided arg
sudo debconf-set-selections <<<"mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
sudo debconf-set-selections <<<"mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"
sudo apt-get -y install mysql-server

#add ondrej PPA
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

#install Mysql server
echo -e "Installing PHP-FPM and Mysql extension for PHP..."
sudo apt-get -y install php7.3-fpm php-mysql

#creating www folder to ngnix
#default user www-data
#edit /etc/nginx/nginx.conf
#vim /etc/php/7.3/fpm/pool.d/www.conf
#
echo -e "Creating www-data folders"
mkdir /var/www
mkdir /var/www/vhosts

sudo chown -R "$USER":www-data /home/www
sudo chmod -R 0755 /home/www
cp /etc/nginx/sites-available/default /home/www/vhosts/default


echo "server {
    listen 80;
    root /home/www/sistema;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name link;
    location / {
        try_files $uri $uri/ /index.php;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        include fastcgi_params;
        fastcgi_buffering on;
        fastcgi_buffers 96 32k;
        fastcgi_buffer_size 32k;
        fastcgi_max_temp_file_size 0;
        fastcgi_keep_conn on;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SCRIPT_NAME $fastcgi_script_name;
    }
    location ~ /\.ht {
        deny all;
    }
}" > /home/www/vhosts/default
