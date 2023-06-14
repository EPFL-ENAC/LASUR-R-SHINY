FROM httpd:2.4

RUN apt -qy update \
    && apt -qy install sed wget build-essential ca-certificates \
    apache2-dev libssl-dev libc-client-dev libkrb5-dev libpq-dev

# Enable SSL
RUN sed -i \
    -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
    -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
    conf/httpd.conf

# Install Tequila
RUN cd / \
    && wget https://tequila.epfl.ch/download/2.0/tequila-apache-C-2.0.17.tgz \
    && tar zxvf tequila-apache-C-2.0.17.tgz
RUN cd /tequila-2.0.17/Apache/C/ \
    && sed -i 's/ && service httpd restart//g' Makefile
RUN cd /tequila-2.0.17/Apache/C/ \
    && make && make install

COPY tequila/tequila.conf /etc/apache2/mods-available/tequila.conf

RUN mkdir /var/tequila \
    && chown www-data: /var/tequila

# Enable proxy
COPY tequila/apache.conf /usr/local/apache2/conf/custom.conf
RUN echo "Include /usr/local/apache2/conf/custom.conf" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80 443
