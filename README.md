##### EXAMPLES

###### INLINE VARIABLES

`PGHOST=foo.bar.com PGPASSWORD=jelszo pg`

###### EXPORTED VARIABLES

```
export PGHOST=foo.bar.com
export PGPASSWORD=jelszo

pg
```

###### DOTENV FILE

`pg ~/.foo.env` (or `pg foo` if `.foo.env` is in the current directory.)

###### EXPORTED DOTENV

```
set -a
. .foo.env
set +a

pg
```
