This repo contains the requisite ingredients for a web-serving Docker container
(plus a helpful wizard). It's intended to be a good starting point for anyone
looking to host a simple website. I built it to satisfy my own self-hosting
needs: [my personal website](https://ian.leinbach.me).

### Requirements

First and foremost, you'll need Docker up and running -- this is a docker
container after all. If your distro uses systemd, try `systemctl status
docker.service`.

Next, you'll need an SSL certificate and key to serve HTTPS. For development,
you can generate a self-signed certificate:

```
openssl req -x509 -newkey rsa:4096 -keyout ___.key -out ___.crt
```

In the process of making your certificate and key, it may ask you for a
passphrase, which you will then need to put in a file as well. Simply:

```
echo "ThisIsMyPassphrase" > ___.pass
```

These three files (key, certificate, and password file) correspond to the `-k`,
`-c`, and `-p` flags of `wizard.sh`. The script won't itself fail without them,
but Nginx will fail to start as it expects them to be configured properly.

### The Server

Every directory in this repo is recursively copied into the container as a
top-level directory with the same name. So, for example: `static/` here becomes
`/static` in the container.

The server will serve requests statically when possible (i.e. when the requested
file can be found in `/static`). Otherwise, the request is forwarded to a
WSGI-compliant backend whose application object must lie in the file
`/code/backend/wsgi.py`. This could be something like Flask or Django.

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

probe    open a bash prompt into a running container
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
the host which is somewhere in `/var/lib/docker/volumes/SERVER_NAME/_data` where
SERVER_NAME is the name given to `wizard.sh`.
