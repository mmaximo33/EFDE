FROM php:8.1-cli

ARG TIMEZONE
ARG APP_PATH=/app
ARG COMPOSER_VERSION=2.5.1

# Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg \
    g++ \
    procps \
    openssl \
    git \
    unzip \
    zlib1g-dev \
    libzip-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libicu-dev  \
    libonig-dev \
    libxslt1-dev \
    acl

# Extra
RUN apt-get update && apt-get install -y mc neovim

# Configure the gd library
RUN docker-php-ext-configure gd --with-jpeg --with-freetype 

RUN docker-php-ext-install \
    pdo pdo_mysql zip xsl gd intl opcache exif mbstring

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
    && printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
    && "date"

# Get composer installed to /usr/local/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer --version

# APP path container project
RUN mkdir -p ${APP_PATH}
RUN groupadd -g 1000 www && useradd -g 1000 -u 1000 -d ${APP_PATH} -s /bin/bash www
VOLUME ${APP_PATH}

WORKDIR ${APP_PATH}

CMD ["bash"]