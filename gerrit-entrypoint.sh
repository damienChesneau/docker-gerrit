#!/bin/bash
set -e

function set_gerrit_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/gerrit.config" "$@"
}

function set_secure_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/secure.config" "$@"
}

if [ "$1" = "/gerrit-start.sh" ]; then
  chown -R ${GERRIT_USER} "${GERRIT_SITE}"

  if [ -z "$(ls -A "$GERRIT_SITE")" ]; then
    echo "First time initialize gerrit..."
    gosu ${GERRIT_USER} java -jar "${GERRIT_WAR}" init --batch --no-auto-start -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS}
    [ ${#DATABASE_TYPE} -gt 0 ] && rm -rf "${GERRIT_SITE}/git"
  fi

    set_gerrit_config auth.type "${AUTH_TYPE}"

  [ -z "${JAVA_HEAPLIMIT}" ] || set_gerrit_config container.heapLimit "${JAVA_HEAPLIMIT}"
  [ -z "${JAVA_OPTIONS}" ]   || set_gerrit_config container.javaOptions "${JAVA_OPTIONS}"
  [ -z "${JAVA_SLAVE}" ]     || set_gerrit_config container.slave "${JAVA_SLAVE}"
  set_gerrit_config plugins.allowRemoteAdmin true

  [ -z "${HTTPD_LISTENURL}" ] || set_gerrit_config httpd.listenUrl "${HTTPD_LISTENURL}"

  echo "Upgrading gerrit..."
  gosu ${GERRIT_USER} java -jar "${GERRIT_WAR}" init --batch -d "${GERRIT_SITE}" ${GERRIT_INIT_ARGS}
  if [ $? -eq 0 ]; then
    echo "Upgrading is OK."
  else
    echo "Something wrong..."
    cat "${GERRIT_SITE}/logs/error_log"
  fi
fi
exec "$@"
