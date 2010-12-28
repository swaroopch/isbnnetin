#!/usr/bin/env ruby

yaml_config = YAML.load_file("#{Rails.root}/config/app_config.yml")

configatron.configure_from_hash(yaml_config['common'])
configatron.configure_from_hash(yaml_config[Rails.env])

#server_config_file = "#{Rails.root}/config/server_config.yml"
#if File.exists?(server_config_file)
  #configatron.configure_from_hash(YAML.load_file(server_config_file))
#end
