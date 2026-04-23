#!/bin/sh


ENV_FILE=


if test -n "$1"; then

	if test -f ".$1.env"; then
		ENV_FILE=".$1.env"
	elif test -f "$1"; then
		ENV_FILE="$1"
	else
		printf " \"$1\" not found. Aborting...\n"
		exit 1
	fi

elif test -f '.env'; then

	ENV_FILE='.env'

fi


if test -n "$ENV_FILE"; then

	set -a
	. "$ENV_FILE"
	set +a

fi


if test -z "$PSQL_PAGER"; then
	PSQL_PAGER='less -SX --header 2'
fi



printf "\n"
printf "      \033[1mENV\033[0m: $ENV_FILE\n"
printf "    \033[1mPAGER\033[0m: $PSQL_PAGER\n"
printf "\n"
printf "     \033[1mHOST\033[0m: $PGHOST\n"
printf "     \033[1mPORT\033[0m: $PGPORT\n"
printf "     \033[1mUSER\033[0m: $PGUSER\n"
printf " \033[1mDATABASE\033[0m: $PGDATABASE\n"
printf "\n"


psql
