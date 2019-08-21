This repo contains the requisite ingredients for a web-serving Docker container
plus a helpful wizard.

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
-n       don't tamper with config files
```

To start the server running and then follow the logs (i.e. print them as they're
generated), you can use the following form of command:

```
$ ./wizard.sh serve website.com -f -c /path/to/certificate.crt -k /path/to/key.key
```
