FROM php:8.1.0alpha1-cli-alpine

RUN apk update && apk upgrade
# Install dependencies
RUN apk add mariadb-client libpng-dev postgresql-dev libssh-dev zip libzip-dev libxml2-dev jpegoptim optipng pngquant gifsicle unzip git libxslt-dev curl rabbitmq-c-dev icu-dev oniguruma-dev

RUN mkdir -p /usr/src/php/ext/xdebug && curl -fsSL https://pecl.php.net/get/xdebug | tar xvz -C "/usr/src/php/ext/xdebug" --strip 1 && docker-php-ext-install xdebug
RUN docker-php-ext-enable xdebug

RUN docker-php-ext-install zip opcache pdo_mysql pdo_pgsql mysqli mbstring bcmath sockets xsl exif gd intl

RUN curl -L -o /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar \
&& chmod +x /usr/local/bin/pickle

# Install extensions
RUN apk add --no-cache $PHPIZE_DEPS \
   && pickle install redis \
   && docker-php-ext-enable redis

WORKDIR /var/www

# Install composer
RUN curl -sS  https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php"]