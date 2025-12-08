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

Rscript -e 'targets::tar_make(-starts_with("p3"))'
Rscript -e 'targets::tar_make(starts_with("p3"))'
