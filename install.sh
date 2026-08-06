#!/bin/sh

CMD_NAME=pg

test "${0##*/}" = 'install.sh' && {
	INSTALL_DIR="${HOME}/.local/bin"
	test -n "$1" && test -d "$1" \
		&& INSTALL_DIR="$1"
	INSTALL_PATH="${INSTALL_DIR}/${CMD_NAME}"
	mkdir -p "$INSTALL_DIR" \
	&& cp -i "$0" "$INSTALL_PATH" \
	&& chmod -v 0755 "$INSTALL_PATH"
	exit
}

_print() {
	printf "\n \033[1;${2}m${1}\033[0m${3}\n\n"
}

panic() {
	_print ERR 31 ": ${1}"
	exit 1
}

print_debug() {
	test -n "$DEBUG" && \
		_print DEBUG 34 ": ${1}"
}

print_ok() {
	_print OK 32 " ${1}"
}

check_command() {
	command -v "$1" >/dev/null \
		|| panic "Cannot find \033[1m${1}\033[0m."
}

set_env() {
	printenv "$1" >/dev/null || export "$1"="$2"
}

DUMP_MODE=""
DUMP_TO=""
ENV_FILE=""
SQL_QUERY=""
PRINT_FORMAT=csv

while [ "$#" -gt 0 ]; do
	case "$1" in
		--version)
			VERSION='v0.2.17 (main) [d5c2b6e]'
			echo "$VERSION"
			exit
			;;
		--uninstall)
			rm -iv "$0"
			exit
			;;
		--update)
			curl -fLsSo "$(command -v "$0")" \
				"https://${CMD_NAME}.angus.sh/install.sh" \
				&& print_ok "\033[1m$($(command -v "$0") --version)\033[0m" \
				|| panic 'Upgrade failed!'
			exit
			;;
		--help)
			curl -LsS "https://${CMD_NAME}.angus.sh/README.md" 2>/dev/null
			exit
			;;
		--env)
			if [ -f "$2" ]; then
				ENV_FILE="$2"
			elif [ -f ".$2.env" ]; then
				ENV_FILE=".$2.env"
			else
				panic "Cannot find \033[1m${2}\033[0m."
			fi
			shift
			;;
		--dump)
			DUMP_TO="$2"
			shift
			;;
		--dump-data)
			DUMP_MODE='--data-only'
			DUMP_TO="$2"
			shift
			;;
		--dump-schema)
			DUMP_MODE='--schema-only'
			DUMP_TO="$2"
			shift
			;;
		--print-format | --fmt)
			PRINT_FORMAT="$2"
			shift
			;;
		--query | -q)
			SQL_QUERY="$2"
			shift
			;;
		--select-from | -Q)
			SQL_QUERY="SELECT * FROM ${2}"
			shift
			;;
		*)
			panic "\033[1m${1}\033[0m is not a recognized argument."
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
	check_command pg_dump
	pg_dump "$DUMP_MODE" > "$DUMP_TO" \
		&& exit \
		|| panic 'Failed to save.'
fi

check_command psql

if [ -n "$SQL_QUERY" ]; then
	test -z "$PRINT_FORMAT" && panic 'No mode specified!'
	NORMAL_PRINT_FORMAT=$(
		printf '%s' "$PRINT_FORMAT" | tr '[:lower:]' '[:upper:]'
	)
	case "$NORMAL_PRINT_FORMAT" in
		CSV)
			psql --csv -c "$SQL_QUERY" \
				--pset pager=off
		;;
		HTML)
			psql --html -c "$SQL_QUERY" \
				--pset pager=off \
			| tr -d '\n' \
			| sed \
				-e 's/ border="1"//g' \
				-e 's/ align="center"//g' \
				-e 's/ valign="top"//g' \
				-e 's/<p>.*<\/p>//' \
				-e 's/>[[:space:]]\+</></g' \
			&& printf "\n"
		;;
		JSON)
			check_command jq
			psql -Atc \
				"SELECT json_agg(t) FROM (${SQL_QUERY}) t" \
			| jq -cM
		;;
		*)
			panic "\"${PRINT_FORMAT}\" is not a recognized output format!"
		;;
	esac
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
