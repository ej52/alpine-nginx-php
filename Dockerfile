FROM ej52/alpine-nginx:latest
MAINTAINER Elton Renda "https://github.com/ej52"

ENV PHP_VERSION=7.0.2

RUN \
  # Install build and runtime packages
  build_pkgs="build-base re2c file readline-dev autoconf binutils bison \
  libxml2-dev curl-dev freetype-dev openssl-dev libjpeg-turbo-dev libpng-dev \
  libwebp-dev libmcrypt-dev gmp-dev icu-dev libmemcached-dev wget git" \
  && runtime_pkgs="curl zlib tar make libxml2 readline freetype openssl \
  libjpeg-turbo libpng libmcrypt libwebp icu" \
  && apk --no-cache add ${build_pkgs} ${runtime_pkgs} \
  
  # download unpack php-src
  && mkdir /tmp/php && cd /tmp/php \
  && wget https://github.com/php/php-src/archive/php-${PHP_VERSION}.tar.gz \
  && tar xzf php-${PHP_VERSION}.tar.gz \
  && cd php-src-php-${PHP_VERSION} \
  
  #compile
  && ./buildconf --force \
  && ./configure \
      --prefix=/usr \
      --sysconfdir=/etc/php \
      --with-config-file-path=/etc/php \
      --with-config-file-scan-dir=/etc/php/conf.d \
      --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data \
      --enable-cli \
      --enable-mbstring \
      --enable-zip \
      --enable-ftp \
      --enable-bcmath \
      --enable-opcache \
      --enable-pcntl \
      --enable-mysqlnd \
      --enable-gd-native-ttf \
      --enable-sockets \
      --enable-exif \
      --enable-soap \
      --enable-calendar \
      --enable-intl \
      --enable-json \
      --enable-dom \
      --enable-libxml --with-libxml-dir=/usr \
      --enable-xml \
      --enable-xmlreader \
      --enable-phar \
      --enable-session \
      --enable-sysvmsg \
      --enable-sysvsem \
      --enable-sysvshm \
      --disable-cgi \
      --disable-debug \
      --disable-rpath \
      --disable-static \
      --disable-phpdbg \
      --with-libdir=/lib/x86_64-linux-gnu \
      --with-curl \
      --with-mcrypt \
      --with-iconv \
      --with-gd --with-jpeg-dir=/usr --with-webp-dir=/usr --with-png-dir=/usr \
      --with-freetype-dir=/usr \
      --with-zlib --with-zlib-dir=/usr \
      --with-openssl \
      --with-mhash \
      --with-pcre-regex \
      --with-pdo-mysql \
      --with-mysqli \
      --with-readline \
      --with-xmlrpc \
      --with-pear \
  && make \
  && make install \
  && make clean \
  
  # strip debug symbols from the binary (GREATLY reduces binary size)
  && strip -s /usr/bin/php \
  
  # remove PHP dev dependencies
  && apk del $buildDeps \
  
  # install composer
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  
   # other clean up
  && cd / \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && rm -rf /var/www/*
  
ADD root /

EXPOSE 80 443
