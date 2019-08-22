This repo contains the requisite ingredients for a web-serving Docker container
(plus a helpful wizard). It's intended to be a good starting point for anyone
looking to host a simple website. I built it to satisfy my own self-hosting
needs: [my personal website](https://ian.leinbach.me).

### Requirements

The only thing you'll need is Docker up and running properly.

### The Server

Every directory in this repo is recursively copied into a top-level directory in
the container with the same name. So, for example: `static/` here becomes
`/static` in the container.

The server will serve requests statically when possible (i.e. when the requested
file can be found in `/static`). Otherwise, the request is forwarded to a
WSGI-compliant backend whose application object must lie in the file
`/code/backend/wsgi.py`. This could be something like Flask or Django.

The server is configured by default for HTTP and HTTPS. It therefore requires
both SSL certificate and key to properly work. These can be provided with the
`-c` and `-k` flags of the wizard script: `wizard.sh`.

### The Script

```
$ ./wizard.sh -h
.-------.
| Usage |
'-------'

./wizard.sh [OPTIONS] MODE NAME

.-------.
| Modes |
'-------'

probe    spin up and open bash prompt into container
serve    spin up and start serving with container

.---------.
| Options |
'---------'

-h       print this help message
-f       print out logs once container is running
-c       SSL certificate
-k       SSL certificate key
-p       SSL password file
-n       don't tamper with config files
```

To start the server running and then follow the logs (i.e. print them as they're
generated), you can use the following form of command:

```
$ ./wizard.sh serve website.com -f -c /path/to/certificate.crt -k /path/to/key.key
```

### Logging

At first, it might be a good idea to set supervisord's logging level to "debug"
in [etc/supervisor/supervisord.conf](etc/supervisor/supervisord.conf). This will
cause supervisord to write its managed processes' (Nginx's and uWSGI's) logs
into its own. That way, when using the `-f` flag with `wizard.sh`, you can see
Nginx and uWSGI logs as well (although admittedly they're a bit crowded in this
format).

Another option for looking at logs is to observe the volume holding the logs on
the host which is somewhere in `/var/lib/docker/volumes` depending on the name
you gave to `wizard.sh`.
