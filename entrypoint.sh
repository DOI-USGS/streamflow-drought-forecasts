#!/bin/bash

if [[ -z "$TIER" ]]; then
	echo "** TIER: test (by default; TIER is unassigned)"
	echo
	echo 'VITE_APP_DATA_TIER="test"' > .Renviron
elif [[ $TIER = "dev" ]]; then
	echo "** TIER: $TIER"
	echo "inherited tier is dev; setting website build tier to test"
	echo
	echo "VITE_APP_DATA_TIER='test'" > .Renviron
else
	echo "** TIER: $TIER"
	echo
	echo "VITE_APP_DATA_TIER='$TIER'" > .Renviron
fi

api_key=$(aws secretsmanager get-secret-value --secret-id USGS/waterdata/api_token --query SecretString --output text | jq '.["API_USGS_PAT"]')
echo "Setting API_USGS_PAT=${api_key} in .Renviron"
echo "API_USGS_PAT=${api_key}" >> .Renviron

Rscript -e 'targets::tar_make()'
