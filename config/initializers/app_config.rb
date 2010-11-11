APP_CONFIG = YAML::load(ERB.new((IO.read("#{RAILS_ROOT}/config/defaults.yml"))).result)[RAILS_ENV].symbolize_keys
