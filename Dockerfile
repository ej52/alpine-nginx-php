FROM ej52/alpine-nginx:latest
MAINTAINER Elton Renda "https://github.com/ej52"

ENV PHP_VERSION=7.0.1

RUN \
  apk --no-cache add ca-certificates wget curl curl-dev grep libtool imagemagick-dev gmp-dev libmcrypt-dev \
  freetype-dev libxpm-dev libwebp-dev libjpeg-turbo-dev libjpeg bzip2-dev openssl-dev krb5-dev libxml2-dev \
  yaml-dev build-base tar make autoconf re2c bison && \
  cd /tmp && \
  wget https://github.com/php/php-src/archive/php-${PHP_VERSION}.tar.gz && \
  tar xzf php-${PHP_VERSION}.tar.gz && \
  cd /tmp/php-src-php-${PHP_VERSION} && \
  ./buildconf --force && \
  ./configure \
  	--prefix=/usr \
  	--sysconfdir=/etc/php/fpm \
    --with-config-file-path=/etc/php/fpm \
    --with-config-file-scan-dir=/etc/php/fpm/conf.d \
    --enable-fpm \
    --enable-mysqlnd \
    --enable-exif \
    --enable-ftp \
    --enable-mbstring \
    --enable-zip \
    --enable-bcmath \
    --enable-pcntl \
    --enable-pdo \
    --enable-session \
    --enable-simplexml \
    --enable-soap \
    --enable-tokenizer \
    --enable-xml \
    --enable-xmlreader \
    --enable-xmlwriter \
    --enable-sockets \
    --enable-fileinfo \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --disable-cgi \
    --with-curl \
    --with-mcrypt \
    --with-iconv \
    --with-gmp \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-webp-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib-dir=/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=/usr \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-openssl \
    --with-zlib \
    --with-zlib-dir=/usr \
    --with-bz2=/usr && \
  make && \
  make install && \
  cp php.ini-production  /etc/php/fpm/php.ini && \
  mv /etc/php/fpm/php-fpm.conf.default /etc/php/fpm/php-fpm.conf
  mv /etc/php/fpm/php-fpm.d/www.conf.default /etc/php/fpm/php-fpm.d/www.conf  
  adduser -D www-data && \
  rm -rf /tmp/* && \
  apk del build-base libtool bash perl gcc g++ wget grep tar make autoconf re2c bison && \
  rm -rf /var/cache/apk/* && \
  rm -rf /var/www/*
  
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/fpm/php.ini && \
    sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php7-fpm.sock/g" /etc/php/fpm/php-fpm.d/www.conf

ADD root /

EXPOSE 80 443
