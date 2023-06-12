FROM httpd:2.4

RUN apt -qy update \
    && apt -qy install ed wget build-essential ca-certificates \
    apache2-dev libssl-dev libc-client-dev libkrb5-dev libpq-dev

# Install Tequila
RUN cd / \
    && wget https://tequila.epfl.ch/download/2.0/tequila-apache-C-2.0.17.tgz \
    && tar zxvf tequila-apache-C-2.0.17.tgz
RUN if cd /tequila-2.0.17/Apache/C/ && make ; then make install; true; else false; fi

COPY tequila/tequila.load /usr/local/apache2/mods-available/tequila.load
COPY tequila/tequila.conf /usr/local/apache2/mods-available/tequila.conf

# Enable proxy
COPY tequila/apache.conf /usr/local/apache2/conf/custom.conf
RUN echo "Include /usr/local/apache2/conf/custom.conf" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80
