#!/usr/bin/env ruby

yaml_config = YAML.load_file("#{Rails.root}/config/app_config.yml")

configatron.configure_from_hash(yaml_config['common'])
configatron.configure_from_hash(yaml_config[Rails.env])
