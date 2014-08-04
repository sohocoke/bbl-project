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


def delta_applied( config, config_delta )
	# special treatment:
	# predicated keys
	# variables

	config_delta.each do |k,v|
		# TODO dereference variables.

		if v.is_a? Hash
			# look for predicate.
			v.each do |inner_k, inner_v|
				if inner_k =~ (/(.+?)\[(.+?)='(.+?)'\]/)
					# key has predicate: find matches in v, set or insert val.
					target_k, predicate_name, val = [ $1, $2, $3 ]

					matching_elems = config[k].select do |elem|
						elem[predicate_name] == val
					end

					case matching_elems.size
					when 0
						puts "no elems under #{k} where #{predicate_name} == #{val}"
					when 2
						raise "multiple elems under #{k} where #{predicate_name} == #{val}"
					else
						matching_elems[0][target_k] = inner_v
					end
				else
					# no predicate in key. anything to do?
				end
			end
		else
			# recur.
			inner_v = delta_applied inner_v

		end
	end

	config
end


def read_templates(app)
	templates + [ YAML.load(File.read("data/apps/#{app}/#{app}.yaml")) ]
end

def read_configs
	YAML.load File.read('data/config/configs.yaml')
end


def targets
	read_configs['targets']
end

def templates
	read_configs['templates']
end


