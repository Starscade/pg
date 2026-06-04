#!/bin/sh


command -v psql > /dev/null \
	|| {
		printf "\n  Cannot find \033[1mpsql\033[0m.\n\n"
		exit 1
	}


ENV="\033[90mHOST\033[0m"


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

	ENV="$ENV_FILE"

fi


if test -z "$PSQL_PAGER"; then
	export PSQL_PAGER='less -SX --header 2'
fi

if test -z "$PGCLIENTENCODING"; then
	export PGCLIENTENCODING=UTF8
fi

if test -z "$PGTZ"; then
	export PGTZ=$(readlink /etc/localtime | sed 's|.*zoneinfo/||')
fi


printf "\n"
printf "      \033[1mENV\033[0m: $ENV\n"
printf "    \033[1mPAGER\033[0m: $PSQL_PAGER\n"
printf " \033[1mENCODING\033[0m: $PGCLIENTENCODING\n"
printf " \033[1mTIMEZONE\033[0m: $PGTZ\n"
printf "\n"
printf "     \033[1mHOST\033[0m: $PGHOST\n"
printf "     \033[1mPORT\033[0m: $PGPORT\n"
printf "     \033[1mUSER\033[0m: $PGUSER\n"
printf " \033[1mDATABASE\033[0m: $PGDATABASE\n"
printf "\n"


PROMPT_TEMPLATE='%[%033[1;7m%] %R %[%033[0m%] '

psql \
	-v PROMPT1="$PROMPT_TEMPLATE" \
	-v PROMPT2="$PROMPT_TEMPLATE"
