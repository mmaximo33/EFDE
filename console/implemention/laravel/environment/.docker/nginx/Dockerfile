FROM nginx:latest

#ENV EFDE_URL="test.lcl"

# Install dependencies
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  zip

# Extra
RUN apt-get update && apt-get install -y mc neovim

COPY ./default.conf /etc/nginx/conf.d/