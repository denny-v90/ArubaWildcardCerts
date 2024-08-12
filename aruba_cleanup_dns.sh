#!/bin/bash

ARUBA_RECORD_URL='https://api.arubabusiness.it/api/domains/dns/record'

if [[ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID ]]; then
	RECORD_ID=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID)
	rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID
fi
if [[ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/API_KEY ]]; then
	API_KEY=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/API_KEY)
	rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/API_KEY
fi
if [[ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/ARUBA_TOKEN ]]; then
	ARUBA_TOKEN=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/ARUBA_TOKEN)
    rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/ARUBA_TOKEN
fi

# Remove the challenge TXT record from the zone
if [[ -n "${RECORD_ID}" && -n "${API_KEY}" && -n "${ARUBA_TOKEN}" ]]; then
    #CANCELLA RECORD
	curl -sS -X DELETE -H "Accept: application/json" -H "Authorization: Bearer ${ARUBA_TOKEN}" -H "Authorization-Key: ${API_KEY}" ${ARUBA_RECORD_URL}/${RECORD_ID} &>> curl.log
fi

if [[ -f curl.log ]]; then
	rm -f curl.log
fi