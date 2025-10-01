FROM node:16.14.0-alpine3.15 as build

USER root
WORKDIR /app
COPY . .

ENV GENERATE_SOURCEMAP false
ENV NODE_OPTIONS --max_old_space_size=4096
ENV DOTNET_SYSTEM_GLOBALOZATION_INVARIANT=1

RUN apk add --no-cache icu-dev && \
    npm install && \
    ls -la /app && \
    npm fund

FROM nginx:1.24-alpine

USER USER

COPY --from=build --chown=user /app/.retype /usr/share/nginx/html