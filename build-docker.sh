#!/bin/bash

# capture the path to this file so we can call on relative scrips without
# having to be in this dir to do it.
set -e
PREFIXPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

[[ -d ScoutSuite ]] || git clone git@github.com:nccgroup/ScoutSuite.git

rm -rf ${PREFIXPATH}/reports
mkdir -p ${PREFIXPATH}/reports

docker build -t scoutsuite-karl ${PREFIXPATH}
