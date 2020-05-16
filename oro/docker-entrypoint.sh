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

    php ./bin/console oro:install --env=prod --timeout=5000 --no-debug --application-url="http://$APP_HOST/" --organization-name="$ORGNAME" --user-name="$APP_USER" --user-email="$APP_USER_EMAIL" --user-firstname="$USER_FIRST_NAME" --user-lastname="$USER_LAST_NAME" --user-password="$APP_PASSWORD" --sample-data=$APP_LOAD_DEMO_DATA --language=de --formatting-code=de_DE

    # fix permissions
    setfacl -b -R ./
    find . -type f -exec chmod 0644 {} + -o -type d -exec chmod 0755 {} +
#    chown -R www-data:www-data ./var/{sessions,attachment,cache,import_export,logs}
#    chown -R www-data:www-data ./public/{media,uploads,js}
    chown -R www-data:www-data /var/www/html/oroapp/

    RUNMODE="run"

fi # End install



if [ "$RUNMODE" = "run" ];
then
    echo "Entering Run-mode"
    supervisord -n -c /etc/supervisor/supervisord.conf
fi
