FROM marvambass/nginx-ssl-php
MAINTAINER MarvAmBass

ENV DH_SIZE 2048

RUN apt-get update; apt-get install -y \
    mysql-client \
    php5-mysql \
    php5-gd \
    php5-geoip \
    php-apc \
    curl \
    zip

# no default - if null it will start piwik in initial mode
ENV PIWIK_MYSQL_USER=

# no default - if null it will start piwik in initial mode
ENV PIWIK_MYSQL_PASSWORD=

# default: mysql
ENV PIWIK_MYSQL_HOST=mysql

# default: 3306 - if you use a different mysql port change it
ENV PIWIK_MYSQL_PORT=3306

# default: piwik - don't use the symbol - in there!
ENV PIWIK_MYSQL_DBNAME=piwik

#default: piwik_
ENV PIWIK_MYSQL_PREFIX=piwik

# default: admin - the name of the admin user
ENV PIWIK_ADMIN=admin

# default: [randomly generated 10 characters] - the password for the admin user
# ENV PIWIK_ADMIN_PASSWORD=

# default: no@no.tld - only needed if you are interested in one of those newsletters
ENV PIWIK_ADMIN_MAIL=no@no.tld

# 1 or 0 - default: 0
ENV PIWIK_SUBSCRIBE_NEWSLETTER=0

# 1 or 0 - default: 0
ENV PIWIK_SUBSCRIBE_PRO_NEWSLETTER=0

# Website to Track Settings
# default: My local Website
# ENV SITE_NAME="My local Website"

# default: http://localhost
ENV SITE_URL=http://localhost

# default: Europe/Berlin
ENV SITE_TIMEZONE=Europe/Berlin

# 1 or 0 - default: 0
ENV SITE_ECOMMERCE=0

# Piwik Track Settings

# 1 or 0 - this will anonymise IPs - default: 1
ENV ANONYMISE_IP=1

# 1 or 0 - this will skip browsers with do not track enabled from tracking - default: 1
ENV DO_NOT_TRACK=1

# Misc Settings

# default: /piwik/ - you can chance that to whatever you want/need
ENV PIWIK_RELATIVE_URL_ROOT=/piwik/

# default: not set - if set to any value the settings to listen behind a reverse proxy server will be removed
# ENV PIWIK_NOT_BEHIND_PROXY=

# default: not set - if set to any value the HTTP Strict Transport Security will be activated on SSL Channel
# ENV PIWIK_HSTS_HEADERS_ENABLE=

# default: not set - if set together with PIWIK_HSTS_HEADERS_ENABLE and set to any value the HTTP Strict Transport Security will be deactivated on subdomains
# ENV PIWIK_HSTS_HEADERS_ENABLE_NO_SUBDOMAINS=

# default: not set - if set Piwik will activate the Plugins named in the Variable, separated by whitespace
# ENV PIWIK_PLUGINS_ACTIVATE=

# Inherited Variables

# default: 2048 if you need more security just use a higher value
ENV DH_SIZE=2048

# clean http directory
RUN rm -rf /usr/share/nginx/html/*

# install nginx piwik config
ADD nginx-piwik.conf /etc/nginx/conf.d/nginx-piwik.conf

# download piwik
RUN curl -O "http://builds.piwik.org/piwik.zip"

# unarchive piwik
RUN unzip piwik.zip

# add piwik config
ADD config.ini.php /piwik/config/config.ini.php

# add startup.sh
ADD startup-piwik.sh /opt/startup-piwik.sh
RUN chmod a+x /opt/startup-piwik.sh

# add '/opt/startup-piwik.sh' to entrypoint.sh
RUN sed -i 's/# exec CMD/# exec CMD\n\/opt\/startup-piwik.sh/g' /opt/entrypoint.sh

# add missing always_populate_raw_post_data = -1 to php.ini (bug #8, piwik bug #6468)
RUN sed -i 's/;always_populate_raw_post_data/always_populate_raw_post_data/g' /etc/php5/fpm/php.ini
