# syntax=docker/dockerfile:1

FROM node:22-alpine AS build
WORKDIR /app

COPY EventNest-UI/package.json EventNest-UI/package-lock.json ./
RUN npm ci

COPY EventNest-UI/ .
RUN npm run build

FROM nginx:alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
