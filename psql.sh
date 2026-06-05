#!/bin/sh

print_err() {
	printf "\n  \033[1;31mERR\033[0m: ${1}\n\n"
	exit 1
}

check_command() {
	command -v "$1" >/dev/null || {
		print_err "Cannot find \033[1m${1}\033[0m."
	}
}

set_env() {
	printenv "$1" >/dev/null || export "$1"="$2"
}

check_command psql

ENV_FILE=""
if [ -n "$1" ]; then
	if [ -f "$1" ]; then
		ENV_FILE="$1"
	elif [ -f ".$1.env" ]; then
		ENV_FILE=".$1.env"
	else
		print_err "Cannot find \033[1m${ENV_FILE}\033[0m."
	fi
elif [ -f ".env" ]; then
	ENV_FILE=".env"
fi

printenv ENV_FILE && {
	. "$ENV_FILE"
	ENV_DISPLAY="$ENV_FILE"
} || ENV_DISPLAY="\033[90mDEFAULT\033[0m"

set_env PGCLIENTENCODING UTF8
set_env PGDATABASE postgres
set_env PGHOST 127.0.0.1
set_env PGOPTIONS "--timezone=$(date +%z | head -c 3)"
set_env PGPORT 5432
set_env PGPROMPT '%[%033[1;7m%] %R %[%033[0m%] '
set_env PGUSER postgres
set_env PSQL_PAGER 'less -SX --header 2'

printf "\n"
printf "      \033[1mENV\033[0m: ${ENV_DISPLAY}\n"
printf "    \033[1mPAGER\033[0m: ${PSQL_PAGER}\n"
printf " \033[1mENCODING\033[0m: ${PGCLIENTENCODING}\n"
printf "  \033[1mOPTIONS\033[0m: ${PGOPTIONS}\n"
printf "\n"
printf "     \033[1mHOST\033[0m: ${PGHOST}\n"
printf "     \033[1mPORT\033[0m: ${PGPORT}\n"
printf "     \033[1mUSER\033[0m: ${PGUSER}\n"
printf " \033[1mDATABASE\033[0m: ${PGDATABASE}\n"
printf "\n"

psql \
	-v PROMPT1="$PGPROMPT" \
	-v PROMPT2="$PGPROMPT" \
	"$@"
