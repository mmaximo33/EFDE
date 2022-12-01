FROM php:fpm-stretch

RUN apt-get update 
RUN apt-get install -y --no-install-recommends \
    git \
    mc \
    neovim \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install \
    zip \
    intl \
    mysqli \
    pdo pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --version

WORKDIR /var/www/html
