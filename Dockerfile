FROM php:apache

LABEL maintainer="elitonluiz1989@gmail.com"
LABEL version="1.0.0"

RUN apt update; \
    apt upgrade;

# install extensions
# intl, zip, soap
RUN apt install -y --no-install-recommends \
    curl \
    wget \
    libzip-dev \
    libc6-dev \
    libicu63 \
    libicu-dev\
    libxml2-dev \
    && docker-php-ext-install intl zip

# mysqli, pdo, pdo_mysql, pdo_pgsql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# mcrypt, gd, iconv
RUN apt install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

# xdebug
RUN docker-php-source extract \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-source delete

RUN echo 'ServerName 127.0.0.1' >> /etc/apache2/conf-available/servername.conf

RUN a2enmod rewrite
RUN a2enconf servername.conf

# Adding composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

CMD ["apachectl", "-D", "FOREGROUND"]