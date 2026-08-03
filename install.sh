#!/bin/sh

test $(basename "$0") = 'install.sh' && {
	INSTALL_DIR=~/.local/bin
	test -n "$1" && test -d "$1" \
		&& INSTALL_DIR="$1"
	INSTALL_PATH="${INSTALL_DIR}/pg"
	mkdir -pv "$INSTALL_DIR" \
	&& cp -iv "$0" "$INSTALL_PATH" \
	&& chmod -v 0755 "$INSTALL_PATH"
	exit
}

print_err() {
	printf "\n  \033[1;31mERR\033[0m: ${1}\n\n"
	exit 1
}

print_ok() {
	printf "\n \033[1;32mOK\033[0m  ${1}\n\n"
}

check_command() {
	command -v "$1" >/dev/null \
		|| print_err "Cannot find \033[1m${1}\033[0m."
}

set_env() {
	printenv "$1" >/dev/null || export "$1"="$2"
}

check_command pg_dump
check_command pg_restore
check_command psql

DUMP_TO=""
ENV_FILE=""
SCHEMA_ONLY=""
SQL_QUERY=""

while [ "$#" -gt 0 ]; do
	case "$1" in
		--version)
			VERSION='v0.2.0 (main)'
			echo "$VERSION"
			exit
			;;
		--uninstall)
			rm -iv "$0"
			exit
			;;
		--update)
			curl -fLsSo "$(command -v "$0")" \
				'https://pg.angus.sh/install.sh' \
				&& print_ok "\033[1m$($(command -v "$0") --version)\033[0m" \
				|| print_err 'Upgrade failed!'
			exit
			;;
		--dump)
			shift
			DUMP_TO="$1"
			;;
		--dump-schema)
			shift
			DUMP_TO="$1"
			SCHEMA_ONLY='--schema-only'
			;;
		--env)
			shift
			if [ -f "$1" ]; then
				ENV_FILE="$1"
			elif [ -f ".$1.env" ]; then
				ENV_FILE=".$1.env"
			else
				print_err "Cannot find \033[1m${1}\033[0m."
			fi
			;;
		--json)
			CSV_TO_JSON=1
			;;
		--query | -q)
			shift
			SQL_QUERY="$1"
			;;
		*)
			print_err "\033[1m${1}\033[0m is not a recognized argument."
			;;
	esac
	shift
done

if [ -n "$ENV_FILE" ]; then
	set -a
	. "$ENV_FILE"
	set +a
	ENV_DISPLAY="$ENV_FILE"
else
	ENV_DISPLAY="\033[90mHOST ENVIRONMENT\033[0m"
fi

set_env PGCLIENTENCODING UTF8
set_env PGDATABASE postgres
set_env PGHOST 127.0.0.1
set_env PGOPTIONS "--timezone=$(date +%z | head -c 3)"
set_env PGPORT 5432
set_env PGPROMPT '%[%033[1;7m%] %R %[%033[0m%] '
set_env PGUSER postgres
set_env PSQL_PAGER 'less -SX --header 2'

if [ -n "$DUMP_TO" ] && [ -d "$(dirname "$DUMP_TO")" ]; then
	pg_dump "$SCHEMA_ONLY" > "$DUMP_TO" \
		&& exit \
		|| print_err 'Failed to save.'
fi

if [ -n "$SQL_QUERY" ]; then
	if [ -n "$CSV_TO_JSON" ]; then
		psql -Atc \
			"SELECT json_agg(t) FROM (${SQL_QUERY}) t"
	else
		psql --csv -c "$SQL_QUERY" \
			--pset pager=off
	fi
else
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
		--pset linestyle=unicode \
		-v PROMPT1="$PGPROMPT" \
		-v PROMPT2="$PGPROMPT"
fi
