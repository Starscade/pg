##### EXAMPLES

###### INLINE VARIABLES

```
PGHOST=foo.bar.com PGPASSWORD=jelszo pg
```

###### EXPORTED VARIABLES

```
export PGHOST=foo.bar.com
export PGPASSWORD=jelszo

pg
```

###### DOTENV FILE

`pg --env ~/.foo.env` (or `pg --env foo` if `.foo.env` is in the current directory.)

###### EXPORTED DOTENV

```
set -a
. .foo.env
set +a

pg
```

###### ONE-LINER SQL
```
pg --sql "SELECT * FROM public.foo ;"
```

###### RAW EXPORT

```
pg --dump ./foo.sql
```
