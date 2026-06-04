#!/bin/sh

# Improve robustness and portability
set -eu

# Check for psql dependency
if ! command -v psql >/dev/null 2>&1; then
	printf "Error: psql not found.\n" >&2
	exit 1
fi

# Determine environment file
ENV_FILE=""
if [ -n "${1:-}" ]; then
	if [ -f ".$1.env" ]; then
		ENV_FILE=".$1.env"
	elif [ -f "$1" ]; then
		ENV_FILE="$1"
	else
		printf "Error: Configuration file '%s' not found.\n" "$1" >&2
		exit 1
	fi
elif [ -f ".env" ]; then
	ENV_FILE=".env"
fi

# Load environment variables
if [ -n "$ENV_FILE" ]; then
	# shellcheck source=/dev/null
	. "$ENV_FILE"
	ENV_DISPLAY="$ENV_FILE"
else
	ENV_DISPLAY="Default"
fi

# Set defaults if not provided
export PSQL_PAGER="${PSQL_PAGER:-less -SX --header 2}"
export PGCLIENTENCODING="${PGCLIENTENCODING:-UTF8}"

if [ -z "${PGTZ:-}" ]; then
	# Portable way to get TZ on many systems
	if [ -h /etc/localtime ]; then
		export PGTZ="$(readlink /etc/localtime | sed 's|.*zoneinfo/||')"
	else
		export PGTZ="UTC"
	fi
fi

# UI Output
cat <<EOF

      ENV: ${ENV_DISPLAY}
    PAGER: ${PSQL_PAGER}
 ENCODING: ${PGCLIENTENCODING}
 TIMEZONE: ${PGTZ}

     HOST: ${PGHOST:-localhost}
     PORT: ${PGPORT:-5432}
     USER: ${PGUSER:-$(whoami)}
 DATABASE: ${PGDATABASE:-postgres}

EOF

# Execute psql
PROMPT_TEMPLATE='%[%033[1;7m%] %R %[%033[0m%] '

psql \
	-v PROMPT1="$PROMPT_TEMPLATE" \
	-v PROMPT2="$PROMPT_TEMPLATE" \
	"$@"
