# REFACTOR: data/config

require 'yaml'

require_relative 'hash_ext'

Base_dir = 'data'


def cascaded_config( app )
    # order of the config files
    config_files = [ "#{Base_dir}/config.yaml" ] + Dir.glob("#{Base_dir}/apps/#{app}/**/config.yaml")

    non_variant_config_files = config_files.reject {|e| e =~ %r(/variants/)}  # exclude variants
    config_chunks = read_config non_variant_config_files

    non_variant_config_files.each_with_index do |f, i|
      if config_chunks[i] == false
        puts "#{f}: content read error"
      end
    end

    # non-variant content
    r = config_chunks.select{|e| e}.cascaded

    # add a 'variants' elem listing cascaded variants with id's.
    variant_files = config_files.select{|e| e =~ %r(/variants/)}
    variants = []
    variant_chunks = read_config variant_files
    variant_chunks.each_with_index do |chunk, i|
        if chunk == false
            puts "#{variant_files[i]}: content read error"
            next
        end

        if chunk['id']
            # we have a node -- insert
            variants << chunk  ## ?? cascade?

            puts "wrote variant #{chunk}"
        end
    end

    r['variants'] = variants

    r
end

def cascaded_variant_config( app, variant_config )
    app_config = cascaded_config(app)
    app_config = app_config.cascaded( variant_config )

    # no nested variants allowed
    app_config.delete 'variants'

    app_config
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


def dereferenced( str, variables )
    variable_ref_p = /\{var:(.+?)\}/  # e.g. {var:my-variable-name}

    matches = str.each_line.map{|e| variable_ref_p.match(e)}.compact
    matches.each do |match_d|
        var = match_d[1]
        raise "no variable '#{var}' defined" unless variables.has_key? var

        str = str.sub(match_d[0], variables[var])
    end

    str
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



    def targets
        Dir.glob("#{Base_dir}/destinations/**/servers.yaml").map {|e| Hash[ 'id', File.basename(File.dirname(e)), 'servers', YAML.load(File.read(e)) ] }
    end


    def read_config(config_files)
        puts "load config from #{config_files}"

        # config objects
        config = config_files.map {|f| YAML.load File.read(f)}
    end

    def debug(msg)
        # puts msg
    end
