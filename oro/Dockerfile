FROM	ubuntu:20.04


ENV	DEBIAN_FRONTEND=noninteractive
ENV	TZ=Europe/Berlin

RUN	apt-get update && apt-get upgrade && \
	apt-get install -y \
	nginx \
	php php-cli php-fpm php-pdo php-mysqlnd php-xml php-soap php-gd php-mbstring php-zip php-intl php-opcache php-curl \
	curl wget \
	git \
	unzip \
	acl \
	supervisor \
	cron \
	make

# set php config
RUN	sed -i 's/user = apache/user = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/group = apache/group = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/;catch_workers_output/catch_workers_output/g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/memory_limit = [0-9MG]*/memory_limit = 1G/g' /etc/php/7.4/fpm/php.ini && \
	sed -i 's/;realpath_cache_size = [0-9MGk]*/realpath_cache_size = 4M/g' /etc/php/7.4/fpm/php.ini && \
	sed -i 's/;realpath_cache_ttl = [0-9]*/realpath_cache_ttl = 600/g' /etc/php/7.4/fpm/php.ini && \
	sed -i 's/opcache.enable=[0-1]/opcache.enable=1/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini && \
	sed -i 's/;opcache.enable_cli=[0-1]/opcache.enable_cli=0/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini && \
	sed -i 's/opcache.memory_consumption=[0-9]*/opcache.memory_consumption=512/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini && \
	sed -i 's/opcache.interned_strings_buffer=[0-9]*/opcache.interned_strings_buffer=32/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini && \
	sed -i 's/opcache.max_accelerated_files=[0-9]*/opcache.max_accelerated_files=32531/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini && \
	sed -i 's/;opcache.save_comments=[0-1]/opcache.save_comments=1/g' /etc/php/7.4/fpm/conf.d/10-opcache.ini


# Nodejs 12 installieren
RUN	curl -sL https://deb.nodesource.com/setup_12.x | sh - && \
	apt-get update && apt-get install -y nodejs

WORKDIR /var/www/html

RUN     git clone https://github.com/oroinc/platform-application.git && \
	mv platform-application oroapp && \
        cd oroapp && \
        git checkout 4.1.3

RUN	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php  composer-setup.php && \
	php -r "unlink('composer-setup.php');" && \
	mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html/oroapp

RUN	composer install --prefer-dist --no-dev

# Add configuration files
ADD     nginx_default.conf /etc/nginx/sites-available/default
ADD     parameters.yml /var/www/html/oroapp/config/parameters.yml
ADD     config.yml /var/www/html/oroapp/config/config.yml
ADD     supervisord.conf /etc/supervisor/conf.d/oro.conf

# fix permissions
RUN	setfacl -b -R ./
RUN	find . -type f -exec chmod 0644 {} + -o -type d -exec chmod 0755 {} +
#RUN	chown -R www-data:www-data ./var/{sessions,attachment,cache,import_export,logs} && \
#	chown -R www-data:www-data ./public/{media,uploads,js}


RUN	echo "*/1 * * * * php /var/www/html/oroapp/bin/console oro:cron --env=prod > /dev/null" > /var/spool/cron/nginx

# setting ownership
RUN     chown -R www-data:www-data .

# command run on container startup
CMD	["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
