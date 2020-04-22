FROM php:7.4-fpm

RUN apt-get update && apt-get install -y --no-install-recommends libzip-dev \
    zip \
    unzip 

# Install the extension
RUN docker-php-ext-install zip \
    pdo_mysql

# Install Xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.remote_autostart=off\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.idekey=VSCODE\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.remote_port=9001\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.remote_handler=dbgp\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.remote_connect_back=0\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    "xdebug.remote_host=host.docker.internal\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini 

EXPOSE 9000

# clean
RUN apt-get autoclean -y && \
    apt-get autoremove -y 

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN adduser docker
USER docker

# set composer bin into path
RUN echo "export PATH=$PATH:~/.composer/vendor/bin\n" >> ~/.bashrc

# Install laravel installer
RUN composer global require "laravel/lumen-installer"

# Set working directory
WORKDIR /app

