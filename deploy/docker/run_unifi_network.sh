#!/bin/bash

# create our folders
mkdir -p \
    /run/unifi/work/ROOT \
    /config/{data,logs}

# create symlinks for config
symlinks=( \
/usr/lib/unifi/data \
/usr/lib/unifi/logs )

for i in "${symlinks[@]}"; do
    if [[ -L "$i" && ! "$i" -ef /config/"$(basename "$i")"  ]]; then
        unlink "$i"
    fi
    if [[ ! -L "$i" ]]; then
        ln -s /config/"$(basename "$i")" "$i"
    fi
done

if [[ -L "/usr/lib/unifi/run" && ! "/usr/lib/unifi/run" -ef "/run/unifi"  ]]; then
    unlink "/usr/lib/unifi/run"
fi
if [[ ! -L "/usr/lib/unifi/run" ]]; then
    ln -s "/run/unifi" "/usr/lib/unifi/run"
fi

if [[ ! -e /config/data/system.properties ]]; then
    if [[ -z "${MONGO_HOST}" ]]; then
        echo "*** No MONGO_HOST set, cannot configure database settings. ***"
        exit 1
    else
        echo "*** Waiting for MONGO_HOST ${MONGO_HOST} to be reachable. ***"
        DBCOUNT=0
        while true; do
            if nc -w1 "${MONGO_HOST}" "${MONGO_PORT}" >/dev/null 2>&1; then
                break
            fi
            DBCOUNT=$((DBCOUNT+1))
            if [[ ${DBCOUNT} -gt 6 ]]; then
                echo "*** Defined MONGO_HOST ${MONGO_HOST} MONGO_PORT ${MONGO_PORT} is not reachable, cannot proceed. ***"
                exit 1
            fi
            sleep 5
        done
        sed -i "s/~MONGO_USER~/${MONGO_USER}/" /defaults/system.properties
        sed -i "s/~MONGO_HOST~/${MONGO_HOST}/" /defaults/system.properties
        sed -i "s/~MONGO_HOST~/${MONGO_FQDN}/" /defaults/system.properties
        sed -i "s/~MONGO_PORT~/${MONGO_PORT}/" /defaults/system.properties
        sed -i "s/~MONGO_DBNAME~/${MONGO_DBNAME}/" /defaults/system.properties
        sed -i "s/~MONGO_PASS~/${MONGO_PASS}/" /defaults/system.properties
        if [[ "${MONGO_TLS}" = "true" ]]; then
            sed -i "s/~MONGO_TLS~/true/" /defaults/system.properties
        else
            sed -i "s/~MONGO_TLS~/false/" /defaults/system.properties
        fi
        if [[ -z "${MONGO_AUTHSOURCE}" ]]; then
            sed -i "s/~MONGO_AUTHSOURCE~//" /defaults/system.properties
        else
            sed -i "s/~MONGO_AUTHSOURCE~/\&authSource=${MONGO_AUTHSOURCE}/" /defaults/system.properties
        fi
        cp /defaults/system.properties /config/data
    fi
fi

# generate key
if [[ ! -f /config/data/keystore ]]; then
    keytool -genkey -keyalg RSA -alias unifi -keystore /config/data/keystore \
    -storepass aircontrolenterprise -keypass aircontrolenterprise -validity 3650 \
    -keysize 4096 -dname "cn=unifi" -ext san=dns:unifi
fi

if [[ -z ${MEM_LIMIT} ]] || [[ ${MEM_LIMIT} = "default" ]]; then
    MEM_LIMIT="1024"
fi

# start the actual runner
java \
 -Xmx"${MEM_LIMIT}M" \
 -Dlog4j2.formatMsgNoLookups=true \
 -Dfile.encoding=UTF-8 \
 -Djava.awt.headless=true \
 -Dapple.awt.UIElement=true \
 -XX:+UseParallelGC \
 -XX:+ExitOnOutOfMemoryError \
 -XX:+CrashOnOutOfMemoryError \
 --add-opens java.base/java.lang=ALL-UNNAMED \
 --add-opens java.base/java.time=ALL-UNNAMED \
 --add-opens java.base/sun.security.util=ALL-UNNAMED \
 --add-opens java.base/java.io=ALL-UNNAMED \
 --add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED \
 -jar /usr/lib/unifi/lib/ace.jar start;