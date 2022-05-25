FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    git \
    libjpeg62-turbo-dev \
    libpng-dev

RUN git clone https://github.com/digininja/DVWA.git /var/www/html

WORKDIR /var/www/html
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install gd pdo pdo_mysql
RUN mv /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php
RUN sed -i 's,127.0.0.1,dvwa_db,g' /var/www/html/config/config.inc.php
RUN cd /var/www/html
RUN chmod a+w /var/www/html/hackable/uploads/ \
    /var/www/html/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
