#!/bin/bash
set -e
echo "Starting Gerrit..."
exec gosu ${GERRIT_USER} $GERRIT_SITE/bin/gerrit.sh start
