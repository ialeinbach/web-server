FROM python:3.7-stretch

LABEL maintainer.name="Ian Leinbach"
LABEL maintainer.email="inleinbach@gmail.com"

EXPOSE 80/tcp 443/tcp

SHELL ["/bin/bash", "-c"]

RUN echo -n supervisor nginx uwsgi \
  | xargs -d ' ' -I %              \
      useradd                      \
        --system                   \
        --no-create-home           \
        --shell /bin/false         \
        --gid www-data             \
        %                          ;

ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1

RUN apt-get update            \
 && pip install --upgrade pip ;

RUN apt-get install -y apt-utils ca-certificates curl gnupg2 lsb-release \
 && echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx"  \
 >> /etc/apt/sources.list.d/nginx.list                                   \
 && curl -fsSL https://nginx.org/keys/nginx_signing.key                  \
  | apt-key add -                                                        \
 && apt-get update                                                       \
 && apt-get install -y nginx                                             ;

RUN pip install supervisor uwsgi flask

RUN rm -rf                                    \
      /{etc,var/log}/{supervisor,nginx,uwsgi} \
      /home                                   \
 && mkdir -p                                  \
      /{etc,var/log}/{supervisor,nginx,uwsgi} \
      /{static,code}                          ;

COPY --chown=supervisor:www-data etc/    /etc/
COPY --chown=nginx:www-data      static/ /static/
COPY --chown=uwsgi:www-data      code/   /code/

RUN chown root:root /etc/ssl/*.{key,crt,pass} \
 && chmod 400 /etc/ssl/*.{key,crt,pass}       ;

RUN echo -n nginx uwsgi              \
  | xargs -d ' ' -I %                \
      chown -R %:www-data /var/log/% ;

RUN find /static                           -type d -exec chmod 555 {} \; \
 && find /static                           -type f -exec chmod 444 {} \; \
 && find /etc/{supervisor,nginx,uwsgi}     -type d -exec chmod 555 {} \; \
 && find /etc/{supervisor,nginx,uwsgi}     -type f -exec chmod 444 {} \; \
 && find /var/log/{supervisor,nginx,uwsgi} -type d -exec chmod 555 {} \; \
 && find /var/log/{supervisor,nginx,uwsgi} -type f -exec chmod 766 {} \; ;

ENTRYPOINT ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
