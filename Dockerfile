FROM php:7.4.3-fpm-alpine

LABEL maintainer="elitonluiz1989@gmail.com"
LABEL version="1.0.0"

RUN apk update; \
    apk upgrade; \
    apk add --no-cache bash;

# install extensions
# intl, zip, soap
RUN apk add --update --no-cache libzip-dev \
    libintl \
    icu \
    icu-dev \
    libxml2-dev \
    && docker-php-ext-install intl zip

# mysqli, pdo, pdo_mysql, pdo_pgsql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# mcrypt, gd, iconv
RUN apk add --update --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

# xdebug
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .phpize-deps-configure \
    && docker-php-source delete


RUN sed -i -e 's/listen.*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.conf

RUN echo "expose_php=0" > /usr/local/etc/php/php.ini

CMD ["php-fpm"]