# Instala as Gems
bundle_check || bundle_install
# Roda nosso servidor
bunde exec puma -C config/puma.rb
