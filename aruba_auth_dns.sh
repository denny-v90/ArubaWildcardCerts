#!/bin/bash

SCRIPT_PATH='/root/script'
DEST_MAIL='your_mail@domain.tld'

exit_error () {
	if ! [[ -z $1 ]]; then
		case $1 in
			127)
				echo -e "\nAruba TOKEN retrieval error.\nCheck parameters or check your connection.\n"
				echo -e "API-KEY: ${API_KEY}\nUsername: ${ARUBA_USER}\nPassword: ${ARUBA_PSW}"
				python ${SCRIPT_PATH}/send_mail.py $DEST_MAIL "$HOSTNAME - Aruba TOKEN retrieval error" "API-KEY: ${API_KEY}\n \
				Username: ${ARUBA_USER}\nPassword: ${ARUBA_PSW}"
				exit 127
				;;
			128)
				echo -e "\nZONE ID retrieval error. Check the following data\n"
				echo -e "DOMAIN: ${DOMAIN}"
				python ${SCRIPT_PATH}/send_mail.py $DEST_MAIL "$HOSTNAME - ZONE ID retrieval error" "DOMAIN: ${DOMAIN}"
				exit 128
				;;
			129)
				echo -e "\nError inserting TXT record. Check the following data\n"
				echo -e "API-KEY: ${API_KEY}\nZone Id: ${ZONE_ID}\nTXT Name: ${TXT_NAME}\nValue: ${CERTBOT_VALIDATION}"
				python ${SCRIPT_PATH}/send_mail.py $DEST_MAIL "$HOSTNAME - Error inserting TXT record" "API-KEY: ${API_KEY}\n \
				Zone Id: ${ZONE_ID}\nTXT Name: ${TXT_NAME}\nValue: ${CERTBOT_VALIDATION}"
				exit 129
				;;
		esac
	else
		echo -e "\nGeneric error"
		python ${SCRIPT_PATH}/send_mail.py $DEST_MAIL "$HOSTNAME - Generic error" "$(date)"
		exit 1
	fi
}

# Get 2nd level domain to request zone ID 
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
if [[ -z $DOMAIN ]]; then
	DOMAIN="$CERTBOT_DOMAIN"
fi

API_KEY='2ec*****-****-****-****-*********dbe'
ARUBA_USER='******.webapi'
ARUBA_PSW='*************'
ARUBA_AUTH_URL='https://api.arubabusiness.it/auth/token'
ARUBA_ZONE_URL="https://api.arubabusiness.it/api/domains/dns/${DOMAIN}/details"
ARUBA_RECORD_URL='https://api.arubabusiness.it/api/domains/dns/record'

# Request Aruba Access Token
ARUBA_TOKEN=$(curl -sS -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization-Key: ${API_KEY}" -d "grant_type=password&username=${ARUBA_USER}&password=${ARUBA_PSW}" ${ARUBA_AUTH_URL} | tee curl.log | jq '.access_token' 2> /dev/null)

if [[ $? -eq 0 && $ARUBA_TOKEN != '' && $ARUBA_TOKEN != 'null' ]]; then
	ARUBA_TOKEN=${ARUBA_TOKEN:1:-1}
	echo "ARUBA_TOKEN: ${ARUBA_TOKEN}"
else
	exit_error 127
fi

echo "CERTBOT_DOMAIN: $CERTBOT_DOMAIN"
echo "DOMAIN: $DOMAIN"
echo "CERTBOT_REMAINING_CHALLENGES: $CERTBOT_REMAINING_CHALLENGES"
echo "CERTBOT_ALL_DOMAINS: $CERTBOT_ALL_DOMAINS"
echo "CERTBOT_VALIDATION: $CERTBOT_VALIDATION"

TXT_NAME="_acme-challenge"

# Request zone ID
ZONE_ID=$(curl -sS -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer ${ARUBA_TOKEN}" -H "Authorization-Key: ${API_KEY}" ${ARUBA_ZONE_URL} | tee -a curl.log | jq '.Id' 2> /dev/null)

if [[ $? -eq 0 && $ZONE_ID != '' && $ZONE_ID != 'null' ]]; then
	echo "ZONE_ID: ${ZONE_ID}"
else
	exit_error 128
fi

# Request to add new TXT record
RECORD_ID=$(curl -sS -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer ${ARUBA_TOKEN}" -H "Authorization-Key: ${API_KEY}" -d '{"IdDomain":'${ZONE_ID}',"Name":"'${TXT_NAME}'","Type":"txt","Content":"\"'${CERTBOT_VALIDATION}'\""}' ${ARUBA_RECORD_URL} | tee -a curl.log | jq '.Id' 2> /dev/null)

if [[ $? -eq 0 && $RECORD_ID != '' && $RECORD_ID != 'null' ]]; then
	echo "RECORD_ID: ${RECORD_ID}"
else
	exit_error 129
fi

# Save info for cleanup
if [ ! -d /tmp/CERTBOT_$CERTBOT_DOMAIN ]; then
        mkdir -m 0700 /tmp/CERTBOT_$CERTBOT_DOMAIN
fi

echo $RECORD_ID > /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID
echo $API_KEY > /tmp/CERTBOT_$CERTBOT_DOMAIN/API_KEY
echo $ARUBA_TOKEN > /tmp/CERTBOT_$CERTBOT_DOMAIN/ARUBA_TOKEN

# Sleep to make sure the change has time to propagate over to DNS
sleep 120
