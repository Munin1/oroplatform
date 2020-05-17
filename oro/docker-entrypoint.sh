#!/bin/sh

RUNMODE=$1 # install or run

if [ -d "/var/www/html/oroapp" ]; then
    echo "App seems to be installed already. At least the files already exist in /var/www/html/oroapp. Hence, we are skipping install process."
    RUNMODE="run"
fi

if [ "$RUNMODE" = "install" ];
then
    sleep 30

    echo "Entering install mode"

    cp -r /opt/oroapp /var/www/html
    cd /var/www/html/oroapp

    php ./bin/console oro:install --env=prod --timeout=50000 --no-debug --application-url="http://$APP_HOST/" --organization-name="$ORGNAME" --user-name="$APP_USER" --user-email="$APP_USER_EMAIL" --user-firstname="$USER_FIRST_NAME" --user-lastname="$USER_LAST_NAME" --user-password="$APP_PASSWORD" --sample-data=$APP_LOAD_DEMO_DATA --language=de --formatting-code=de_DE --verbose

    # fix permissions
    setfacl -b -R ./
    find . -type f -exec chmod 0644 {} + -o -type d -exec chmod 0755 {} +
    chown -R www-data:www-data /var/www/html/oroapp/

    RUNMODE="run"

fi # End install



if [ "$RUNMODE" = "update" ]; then

    sleep 30
    echo "Entering update mode"

    cp -r /opt/oroapp /var/www/html
    cd /var/www/html/oroapp
    
    # clear cache
    rm -rf var/cache/prod
    
    # update code
    php ./bin/console oro:platform:update --env=prod --force --skip-assets
    nice --adjustment=-15 php ./bin/console oro:assets:install --env=prod --timeout 50000 --verbose
    
    # update parameters.yml
    sed -i "s/    installed:              ~/    installed:              '$(date --iso-8601=seconds)'/g" config/parameters.yml
    sed -i "s/~/null/g" config/parameters.yml
    
    # clear cache
    php ./bin/console cache:clear --env=prod
    php ./bin/console cache:warmup --env=prod


    # fix permissions
    setfacl -b -R ./
    find . -type f -exec chmod 0644 {} + -o -type d -exec chmod 0755 {} +
    chown -R www-data:www-data /var/www/html/oroapp/

    RUNMODE="run"
fi


if [ "$RUNMODE" = "run" ];
then
    echo "Entering Run-mode"
    supervisord -n -c /etc/supervisor/supervisord.conf
fi
