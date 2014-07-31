# REFACTOR: data/config

require 'yaml'

require_relative 'hash_ext'

def cascaded_configs( app )
	templates = read_configs['templates']
	worxweb_config = YAML.load File.read("data/apps/#{app}/#{app}.yaml")

	# validate existence of ids
	(templates + [ worxweb_config]).each do |c|
		raise "id not found in config: #{c}" unless c['id']
	end

	ids = (templates + [worxweb_config]).map {|e| e['id']}

	templates[0].cascaded templates[1..-1], { "id" => "configuration combined from #{ids}" }
end

# e.g.
# doit 'worxweb'



def read_configs
	YAML.load File.read('data/config/configs.yaml')
end

def targets
	configs = read_configs
	configs['targets']
end

