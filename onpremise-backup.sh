#!/bin/bash

BACKUP_PATH="/backup/dongle"


# Service Deployment
tar -czf "${BACKUP_PATH}/service/service-$(date +'%Y%m%d').tar.gz" /home/sehyoung/service && find "${BACKUP_PATH}/service" -type f -name 'service-*' -mtime +7 -exec rm {} \;

# PostgreSQL Dump
docker compose -p dongle exec postgres pg_dump -U postgres postgres > "${BACKUP_PATH}/db_dump/dongle-$(date +'%Y%m%d').sql" && find "${BACKUP_PATH}/db_dump" -type f -name 'dongle-*' -mtime +7 -exec rm {} \;

# FileSystem Resources
docker run --rm --volumes-from dongle-test-1 -v "${BACKUP_PATH}/resources/users:/backup" ubuntu:22.04 tar czf /backup/users-$(date +'%Y%m%d').tar.gz /data/dongle/users  && find "${BACKUP_PATH}/resources/users" -type f -name 'users-*' -mtime +7 -exec rm {} \;