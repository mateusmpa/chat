FROM ruby:2.3-slim
# Instala nossas dependências
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential nodejs libpq-dev
# Seta nosso path
ENV INSTALL_PATH /chat
# Cria nosso diretório
RUN mkdir -p $INSTALL_PATH
# Seta nosso path como o diretório principal
WORKDIR $INSTALL_PATH
# Copia nosso Gemfile para dentro do container
COPY Gemfile ./
# Seta o path para as gems
ENV BUNDLE_PATH /box
# Copia nosso código para dentro do container
COPY . .
