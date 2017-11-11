# Instala as Gems
bundle_check || bundle_install
# Roda nosso servidor
bundle exec puma -C config/puma.rb
