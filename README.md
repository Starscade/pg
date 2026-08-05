A convenience script for interfacing with PostgreSQL.

---
### USAGE


###### INSTALL

```sh
curl -fLsSo ~/.local/bin/pg pg.angus.sh/install.sh
chmod +x ~/.local/bin/pg
```


###### EXAMPLE QUERIES

Below is a typical one-liner for executing a query via psql.
```sh
psql -h <host> -p <port> -U <user> -d <database> -c 'SELECT * FROM foo'
```

The same result could be accomplished with `pg` as:
```sh
pg --env .env -q 'SELECT * FROM foo'
```

We can even pull variables from the environment.
Even if no variables are present, `pg` will attempt to connect to any localhost
instance of PostgreSQL:
```sh
pg -q 'SELECT * FROM foo'
```

But hold on, `psql` can do this, too! Granted. Let's cut to the chase...
```sh
pg -Q foo
```

One thing you'll notice in all of this is that `pg` hasn't been printing
regular tables on output. They're CSV. By default, `pg` uses the `--csv` and
`-t` flags to produce a clean data stream that can be piped directly to a file.

PostgreSQL also has an HTML option: `--html`. We can utilize this in `pg` via:
```sh
pg -Q foo --mode html
```

If you're writing a script which needs to switch between modes, `pg`'s `--mode`
option can be set to `csv` to achieve the default behavior:
```sh
pg -Q foo --mode csv
```

Again, this can all be accomplished with stock `psql`, but the advantage here
is uniformity. Plus, it allows us to add additional table formats in the
without breaking backwards compatibility. For example:
```sh
pg -Q foo --mode json
```

Of course, working directly inside the PostgreSQL REPL is probably what you'll
be doing most of the time.
```sh
pg
```

This functions exactly like the command line in `psql` (because it is), but
with a few options enabled by default such as a custom prompt and table style.
