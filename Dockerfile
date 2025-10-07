FROM node:16.14.0-alpine3.15 as build

USER root
WORKDIR /app
COPY . .

ENV GENERATE_SOURCEMAP false
ENV NODE_OPTIONS --max_old_space_size=4096
ENV DOTNET_SYSTEM_GLOBALOZATION_INVARIANT=1

RUN microdnf install libicu-devel --nodocs --setopt=install_weak_deps=0 --best \
    && npm install \
    && npm run re-build

FROM nginx:1.24-alpine

USER USER

COPY --from=build --chown=user /app/.retype /usr/share/nginx/html