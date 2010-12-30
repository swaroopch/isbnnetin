#!/usr/bin/env ruby

config_file = Rails.root.join("config", "app_config.yml")
yaml_config = YAML.load_file(config_file)

# https://github.com/markbates/configatron/
configatron.configure_from_hash(yaml_config['common'])
configatron.configure_from_hash(yaml_config[Rails.env])
