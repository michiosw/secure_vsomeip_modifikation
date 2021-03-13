#!/bin/bash
# Copyright (C) 2019 Marco Iorio (Politecnico di Torino)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [[ $# -ne 6 && $# -ne 7 ]]
then
	echo "Usage: $0 remote_path lib_dir conf_dir log_dir log_name messages_to_send [async]"
	exit 1
fi

REMOTE_PATH=$1
LIB_DIR=$2
CONF_DIR=$3
LOG_DIR=$4
LOG_NAME=$5
MESSAGES=$6

[[ $7 == "async" ]] && SYNC="async" || SYNC="sync"

echo "Request/Response benchmark --- Messages: ${MESSAGES}, Mode: ${SYNC}"
export LD_LIBRARY_PATH="${LIB_DIR}"

mkdir -p "${LOG_DIR}"

##### Local Communication #####

# Start the service
export VSOMEIP_APPLICATION_NAME=bench_request_response_service
export VSOMEIP_CONFIGURATION="${CONF_DIR}/bench_request_response_service.json"
echo "> Starting the service..."
./bench_request_response_service &
# 2>> ${LOG_DIR}/bench_request_response_service_stderr &
SERVICE_PID=$!
sleep 1;

# Start the client which sends messages over local UDS
export VSOMEIP_APPLICATION_NAME=bench_request_response_client
export VSOMEIP_CONFIGURATION="${CONF_DIR}/bench_request_response_client_local.json"
echo "> Starting the local client..."
./bench_request_response_client --${SYNC} --number-of-messages ${MESSAGES} 
# --dont-shutdown-service 
# > ${LOG_DIR}/${SYNC}_${LOG_NAME}_loc 2>> ${LOG_DIR}/bench_request_response_client_loc_stderr


##### UDP and TCP Communication #####

# echo "> Starting the remote clients..."
# REMOTE_COMMAND="${REMOTE_PATH}/bench_request_response_slave.sh ${REMOTE_PATH} ${LIB_DIR} ${CONF_DIR} ${LOG_DIR} ${LOG_NAME} ${MESSAGES} ${SYNC}"
# echo "${REMOTE_COMMAND}"
# ssh 192.168.192.3 "${REMOTE_COMMAND}"
# </dev/null >/dev/null 2>&1 &"

# Wait until service is finished
# The client remotely shuts down the service if he has successfully transmitted
# all the packets with different payloads.
wait ${SERVICE_PID}
echo "> Service terminated..."
