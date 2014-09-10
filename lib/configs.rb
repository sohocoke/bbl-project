# REFACTOR: data/config

require 'yaml'

require_relative 'hash_ext'

Base_dir = 'data'


def policy_applied policy_xml, policy_delta
    # getting the Document
    doc = XML::Document.string policy_xml    

    policy_delta.each do |k, v|
        predicate_val = /.+\[.+='(.*)'\]/.match(k)[1]
        
        p "applying value '#{v}' to policy '#{predicate_val}'"
        
        # grabbing the node
        node = doc.find("/PolicyMetadata/Policies/Policy[PolicyName='#{predicate_val}']/PolicyDefault").first

        raise "couldn't find node #{predicate_val}" if node.nil?
        # TODO assert only 1.

        # modifying the node
        node.content = v.to_s
    end

    doc.to_s
end


#= object-based operations

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

    config_chunks.select{|e| e}.cascaded
end

def variants(app)
    app_dir = "data/apps/#{app}"
    raise "no app set up at #{app_dir}" unless File.exists?(app_dir)

    # enum variant files.
    files = Dir.glob "#{app_dir}/variants/**/config.yaml"

    # transform and filter leaf nodes.
    chopped = files.map {|e| [ File.dirname(e), File.basename(e) ]}
    leafs = chopped.select {|e| (o = YAML.load(File.read(e.join('/')))) && o['id']}

    # collect cascaded configs.
    leafs .map do |path, basename|
      superpaths = (chopped - leafs).select {|p, b| path.index(p) }
      superpath_configs = superpaths.map {|p, b| YAML.load File.read("#{p}/#{b}")}

      # remove non-content elements.
      superpath_configs = superpath_configs.select {|e| e}

      leaf_config = YAML.load File.read("#{path}/#{basename}")
      (superpath_configs + [leaf_config]).cascaded.merge({'id'=> leaf_config['id']})
    end
end


def variables(env_name)
    variables_files = Dir.glob("#{Base_dir}/destinations/**/variables.yaml")

    # find dirs leading up to dir for env_name
    dir_for_env_name = Dir.glob("#{Base_dir}/destinations/**/#{env_name}")[0]
    # find variable files in order
    current_path = ''
    variables_files = dir_for_env_name.split('/').map do |path_segment|
        current_path += path_segment + '/'
        Dir.glob("#{current_path}/variables.yaml")[0]
    end .compact

    p variables_files
    hashes = variables_files.map {|e| (o = YAML.load(File.read(e))) ? o : {} }
    hashes.cascaded
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
                raise "no match in config for predicate #{predicate_name}='#{predicate_val}'"
            when 2
                raise "multiple matches config for #{predicate_name}='#{predicate_val}'"
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

    raise "variables are required" if (! matches.empty? && variables.nil?)

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



    def targets(pattern)
        Dir.glob("#{Base_dir}/destinations/**/servers.yaml")
            .map {|e| Hash[ 'id', File.basename(File.dirname(e)), 'servers', YAML.load(File.read(e)) ] }
            .select {|e| e['id'] =~ /#{pattern}/}
    end

    def read_config(config_files)
        puts "load config from #{config_files}"

        # config objects
        config = config_files.map {|f| YAML.load File.read(f)}
    end

    def debug(msg)
        # puts msg
    end



# ### test
#     require 'fileutils'
#     require 'xml'
#     policy_delta = YAML.load(File.read("#{File.dirname(__FILE__)}/../build/WorxMail-test-ios-config.yaml"))['manifest_values']['policies']
#     apply_policy_delta "#{File.dirname(__FILE__)}/../build/WorxMail-test-ios.mdx.unzipped/policy_metadata.xml", policy_delta
