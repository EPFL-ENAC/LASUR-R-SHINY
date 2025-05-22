FROM httpd:2.4

RUN apt -qy update \
    && apt -qy install sed wget
# build-essential ca-certificates \
# apache2-dev libssl-dev libc-client-dev libkrb5-dev libpq-dev

# Install Apache OpenIDC
RUN cd / \
    && wget https://github.com/OpenIDC/mod_auth_openidc/releases/download/v2.4.16.8/libapache2-mod-auth-openidc_2.4.16.8-1.bookworm_amd64.deb \
    && apt-get -qy install ./libapache2-mod-auth-openidc_2.4.16.8-1.bookworm_amd64.deb

# Enable SSL
RUN sed -i \
    -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
    -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
    -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
    /usr/local/apache2/conf/httpd.conf

RUN echo "\nInclude /usr/local/apache2/conf/custom.conf\n" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80 443
