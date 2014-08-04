# REFACTOR: data/config

require 'yaml'

require_relative 'hash_ext'

def cascaded_configs( app )
	templates = read_templates app

	# validate existence of ids
	templates.each do |c|
		raise "id not found in config: #{c}" unless c['id']
	end

	ids = templates.map {|e| e['id']}

	templates[0].cascaded *templates[1..-1], { "id" => "configuration combined from #{ids}" }
end

# e.g.
# doit 'worxweb'

def read_templates(app)
	read_configs['templates'] + [ YAML.load(File.read("data/apps/#{app}/#{app}.yaml")) ]
end

def read_configs
	YAML.load File.read('data/config/configs.yaml')
end

def targets
	configs = read_configs
	configs['targets']
end

