#!/usr/bin/bash

set -euo pipefail

GENPASSWD() {
    openssl passwd hex 1 2 3 4 5 6|tr -d '/\n'
}

USERNAME=montree
DB_NAME=montree
DB_DOCKER_NAME=montree-postgres
PORT=4000
OUT_PORT=${OUT_PORT:-8080}

TT_DOCKER_NAME=${TT_DOCKER_NAME:-montree}

if [ `docker ps -a --filter=name="${DB_DOCKER_NAME}"|wc -l` -eq 1 ]; then
    PASSWORD="`GENPASSWD`"

    docker run --name ${DB_DOCKER_NAME} -e POSTGRES_PASSWD="$PASSWORD" \
                                        -e POSTGRES_USER=$USERNAME   \
                                        -e POSTGRES_DB=${DB_NAME}    \
                                        -d postgres

    # Wait for the DB to be active
    set +e
    for i in `seq 1 120`;do 
        docker exec -i ${DB_DOCKER_NAME} psql -U montree < /dev/null >>/dev/null 2>>/dev/null
        if [ $? -eq 0 ]; then
            break
        fi
        printf "."
        sleep .5
    done
    set -e

    docker exec -i ${DB_DOCKER_NAME} psql -U montree < "./priv/repo/structure.sql"
else
    docker start ${DB_DOCKER_NAME}
fi


DB_DOCKER_ID=`docker ps -a --filter=name="${DB_DOCKER_NAME}"|tail -n+2|cut -d\  -f1`

PASSWORD=`docker inspect ${DB_DOCKER_ID} | jq '.[0].Config.Env'|grep POSTGRES_PASSWD|cut -d= -f2|cut -d\" -f1`

docker run -d --name ${TT_DOCKER_NAME} -m 500m -p ${OUT_PORT}:${PORT} \
                                    --link=${DB_DOCKER_NAME}:db \
                                    -e DATABASE_URL=postgres://${USERNAME}:${PASSWORD}@db:5432/${DB_NAME} \
                                    -e SECRET_KEY_BASE="`GENPASSWD`" \
                                    -e PORT=${PORT} \
                                    -e MIX_ENV=prod \
                                    montree
