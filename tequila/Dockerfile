FROM php:8.2-apache
RUN docker-php-ext-install pdo pdo_mysql

RUN apt -qy update \
    && apt -qy install ed wget build-essential ca-certificates \
    apache2-dev libssl-dev libc-client-dev libkrb5-dev libpq-dev

# Install Tequila
RUN cd / \
    && wget https://tequila.epfl.ch/download/2.0/tequila-apache-C-2.0.17.tgz \
    && tar zxvf tequila-apache-C-2.0.17.tgz
RUN cd /tequila-2.0.17/Apache/C/ \
    && ed - Makefile <<EOFMakefile
g/httpd /s:httpd :apache2 :
g/apxs/s:apxs :apxs2 :
wq
EOFMakefile
RUN cd /tequila-2.0.17/Apache/C/ \
    && make && make install

COPY tequila/tequila.load /etc/apache2/mods-available/tequila.load
COPY tequila/tequila.conf /etc/apache2/mods-available/tequila.conf

RUN mkdir /var/tequila \
    && chown www-data: /var/tequila \
    && a2enmod tequila

# Enable proxy
RUN a2enmod proxy proxy_http
COPY tequila/apache.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80
