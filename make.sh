#!/bin/sh
#
# open-ortho orthanc v0.1.1
#
# Prepare all config files and deploy them.
#

DIST="./dist"
DEST_SERVER="orthanc"
DEST_FOLDER="/usr/local/lib/orthanc"
DEST="${DEST_SERVER}:${DEST_FOLDER}"

# username@ip_address of server which contains SSL certificates to grab.
CERTIFICATE_SERVER="username@server_name.lan"

# Location for Orthanc configuration
ORTHANC_CONFIG="\/usr\/local\/etc\/orthanc"

# Location where Orthanc stores it's data. Escape slashes for sed.
ORTHANC_DATA_MOUNT="\/mnt\/orthanc"

# Location where PostgreSQL will store data folder.
POSTGRESQL_DATA="\/var\/lib\/postgresql\/data"

# Destination for PostgreSQL database dumps
POSTGRESQL_DB_DUMP="\/mnt\/orthanc\/index\/postgres-backup.sql"

# Name of docker image of PostgreSQL
POSTGRESQL_DOCKER_IMAGE="orthanc_orthanc-index_1"

# Location of docker-compose binary
DOCKER_COMPOSE="\/usr\/local\/bin"

clean (){
    rm -rf "${DIST}"
}

init (){
    mkdir "${DIST}"
}

build (){
    cp -Rv docker/postgresql "${DIST}"
    cp -Rv bin "${DIST}"
    cp -Rv etc "${DIST}"
    substitution
}

substitution (){
    # Substitute all $<> variables
    find ${DIST} -type f -exec sed -i "s/\$<ORTHANC-DATA-MOUNT>/${ORTHANC_DATA_MOUNT}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<POSTGRESQL_DATA>/${POSTGRESQL_DATA}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<POSTGRESQL_DOCKER_IMAGE>/${POSTGRESQL_DOCKER_IMAGE}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<POSTGRESQL_DB_DUMP>/${POSTGRESQL_DB_DUMP}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<DOCKER-COMPOSE>/${DOCKER_COMPOSE}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<ORTHANC-CONFIG>/${ORTHANC_CONFIG}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<ORTHANC-IP>/${ORTHANC_IP}/g" {} \;
    find ${DIST} -type f -exec sed -i "s/\$<CERTIFICATE_SERVER>/${CERTIFICATE_SERVER}/g" {} \;
}

deploy (){
    # Fully expanded rsync options. Same as -auv, except without --time --perms
    rsync --links --owner --group --recursive --update --verbose --devices --specials "${DIST}/" "${DEST}/"
    echo "WARNING!! Next step will prompt for root password, and restart orthanc server !!"
    echo "Ctrl-C to interrupt"
    read
    ssh -t "${DEST_SERVER}" "sudo ${DEST_FOLDER}/bin/orthanc_restart.sh"
}

usage () {
    echo "if this was a real script you would see something useful here"
    echo ""
    echo "./simple_args_parsing.sh"
    echo "\t-h --help"
    echo "\t--environment=$ENVIRONMENT"
    echo "\t--db-path=$DB_PATH"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=$(echo $1 | awk -F= '{print $1}')
    VALUE=$(echo $1 | awk -F= '{print $2}')
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        all)
            clean || exit
            init || exit
            build || exit
            ;;
        init)
            init
            ;;
        clean)
            clean
            ;;
        build)
            build
            ;;
        deploy)
            deploy
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done