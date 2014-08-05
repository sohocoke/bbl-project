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

	new_config = config.dup

	config_delta.each do |k,v|
		# TODO dereference variables.

		if has_predicate? k

			vals = new_config

			target_k, predicate_name, predicate_val = decompose k

			# predicated keys only make sense when we're dealing with arrays.
			raise "element in '#{k}' should be an array" unless config.is_a? Array

			matching_vals = vals.select do |val|
				val[predicate_name] == predicate_val
			end

			case matching_vals.size
			when 0
				raise "no match in #{vals} for #{predicate_name}=#{predicate_val}"
			when 2
				raise "multiple matches in #{vals} for #{predicate_name}=#{predicate_val}"
			else
				debug "set #{target_k} on #{matching_vals[0]}"
				matching_vals[0][target_k] = v
			end
		else
			# no predicate in key
			# recur with val if hash.
			if v.is_a? Hash
				debug "recursively handling #{v} for key #{k} with config #{config}"
				new_config[k] = delta_applied config[k], v
			else
				# val in delta is a non-hash: just set.
				new_config[k] = v
			end
		end
	end

	new_config
end

private 
	def decompose(key)
		if key =~ (/(.+?)\[(.+?)='(.+?)'\]/)
			[ $1, $2, $3 ]
		else
			raise "can't decompose key #{key_with_predicate}"
		end
	end

	def has_predicate?(key)
		key =~ (/(.+?)\[(.+?)='(.+?)'\]/)
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



	def debug(msg)
		# puts msg
	end
