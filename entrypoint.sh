#!/bin/bash

if [[ -z "$TIER" ]]; then
	echo "** TIER: test (by default; TIER is unassigned)"
	echo
	echo 'VITE_APP_DATA_TIER="test"' > .Renviron
else
	echo "** TIER: $TIER"
	echo
	echo "VITE_APP_DATA_TIER='$VITE_APP_DATA_TIER'" > .Renviron
fi

Rscript -e 'targets::tar_make()'
