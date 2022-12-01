FROM nginx:latest
# Install dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  zip \
  mc \
  neovim

COPY ./.docker/nginx/default.conf /etc/nginx/conf.d/