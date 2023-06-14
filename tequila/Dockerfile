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

RUN mkdir /var/tequila \
    && chown www-data: /var/tequila
RUN mkdir /var/log/apache2/ \
    && chown www-data: /var/log/apache2/

# Enable proxy
COPY tequila/tequila.conf /usr/local/apache2/conf/tequila.conf
COPY tequila/apache.conf /usr/local/apache2/conf/custom.conf
RUN echo "\n\
    Include /usr/local/apache2/conf/tequila.conf\n\
    Include /usr/local/apache2/conf/custom.conf\n" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80 443
