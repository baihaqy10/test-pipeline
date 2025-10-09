FROM registry.access.redhat.com/ubi8/nodejs-14:latest as build

USER root
WORKDIR /app
COPY . .

ENV GENERATE_SOURCEMAP false
ENV NODE_OPTIONS --max_old_space_size=4096
ENV DOTNET_SYSTEM_GLOBALOZATION_INVARIANT=1

RUN dnf install -y libicu-devel --nodocs --setopt=install_weak_deps=0 --best \
    && npm install \
    && npm run re-build

FROM nginx:1.24-alpine

COPY --from=build  /app/.retype /usr/share/nginx/html

RUN rm -f /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_tmp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx/ \
    && chmod -R 777 /var/cache/nginx/

#RUN sed -i 's/listen    80;/listen      8080;/' /etc/nginx/nginx.conf \
#    && sed -i 's/listen \[::\]:80/listen [::]:8080/' /etc/nginx/conf.d/default.conf \
#   && sed -i '/^user nginx;/d' /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/conf.d 

COPY --from=build  default.conf /etc/nginx/conf.d/default.conf

RUN sed -i '/^user nginx;/d' /etc/nginx/nginx.conf

EXPOSE 8080