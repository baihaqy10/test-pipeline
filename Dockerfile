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
RUN mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_tmp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx/ \
    && chmod -R 777 /var/cache/nginx/

EXPOSE 80