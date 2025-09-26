#!/bin/bash

if [[ -z "$VITE_APP_DATA_TIER" ]]; then
	echo "** TIER: test (by default; VITE_APP_DATA_TIER is unassigned)"
	echo
	echo 'VITE_APP_DATA_TIER="test"' > .Renviron
else
	echo "** TIER: $VITE_APP_DATA_TIER"
	echo
	echo "VITE_APP_DATA_TIER='$VITE_APP_DATA_TIER'" > .Renviron
fi

Rscript -e 'targets::tar_make()'
