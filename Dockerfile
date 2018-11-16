# Download base image ubuntu 16.04
FROM ubuntu:16.04

# Update Ubuntu Software repository
RUN apt-get update

# Install cURL
RUN apt-get install -y curl

# Get certificate for Node.js v6.*
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Install nginx, php-fpm and nodejs from ubuntu repository
RUN apt-get install -y --force-yes \
    git \
    unzip \
    libmcrypt-dev \
    zlib1g-dev \
    nginx \
    php7.0-common \
    php7.0-cli \
    php7.0-curl \
    php7.0-fpm \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-xml \
    php7.0-zip \
    nodejs \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Enable PHP Extensions
RUN phpenmod pdo_mysql
RUN phpenmod mcrypt

# Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf

# Enable php-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

# Install Gulp and Bower
RUN npm install -g gulp bower

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN rm composer-setup.php

# Move composer to /usr/local/bin
RUN mv composer.phar /usr/local/bin/composer

# Install dependencies globally for fast installation in local project
RUN composer global require laravel/framework "5.3.*"
RUN composer global require laravel/socialite "^2.0"
RUN composer global require laravel/scout "^1.1"
RUN composer global require laravelcollective/html "^5.3.0"
RUN composer global require phpunit/phpunit "5.3.*"

# Changed ownership of /var/www/html
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Configure Port
EXPOSE 80 443
