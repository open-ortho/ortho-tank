DIST = ./dist
DEST_SERVER = orthanc

# username@ip_address of server which contains SSL certificates to grab.
CERTIFICATE_SERVER = username@server_name.lan

# Location for Orthanc configuration
ORTHANC_CONFIG = /usr/local/etc/orthanc

# Location where Orthanc stores it's data. Escape slashes for sed.
ORTHANC_DATA_MOUNT = /mnt/orthanc

# Location where PostgreSQL will store data folder.
POSTGRESQL_DATA = /var/lib/postgresql/data

# Destination for PostgreSQL database dumps
POSTGRESQL_DB_DUMP = /mnt/orthanc/index/postgres-backup.sql

# Name of docker image of PostgreSQL
POSTGRESQL_DOCKER_IMAGE = orthanc_orthanc-index_1

# Location of docker-compose binary
DOCKER_COMPOSE = /usr/local/bin

.PHONY: clean all substitution

clean:
	rm -rf $(DIST)

all: $(DIST)/bin $(DIST)/etc $(DIST)/docker substitution

$(DIST):
	mkdir $(DIST)

$(DIST)/bin: $(DIST)
	cp -Rv bin $@

$(DIST)/etc: $(DIST)
	cp -Rv etc $@

$(DIST)/docker: $(DIST)
	cp -Rv docker $@

substitution:
# Substitute all $<> variables
	find $(DIST) -type f -exec sed -i "s#\$$<ORTHANC_DATA_MOUNT>#${ORTHANC_DATA_MOUNT}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<POSTGRESQL_DATA>#${POSTGRESQL_DATA}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<POSTGRESQL_DOCKER_IMAGE>#${POSTGRESQL_DOCKER_IMAGE}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<POSTGRESQL_DB_DUMP>#${POSTGRESQL_DB_DUMP}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<DOCKER_COMPOSE>#${DOCKER_COMPOSE}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<ORTHANC_CONFIG>#${ORTHANC_CONFIG}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<ORTHANC_IP>#${ORTHANC_IP}#g" {} \;
	find $(DIST) -type f -exec sed -i "s#\$$<CERTIFICATE_SERVER>#${CERTIFICATE_SERVER}#g" {} \;