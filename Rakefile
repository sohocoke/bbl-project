require 'json'
require 'xml'
require 'rake/packagetask'
require_relative 'lib/configs'

# FIXME: make all curl -v output go to stdout.
# TODO: capture all shell execution output, do some sanity checks for errors. (grep 'HTTP/1.1')
# TODO: parameterise arguments related to android signing.

Pattern_variable = /\{var:.+\}/

## env

log_dir = "log/"
build_dir = "build/"
data_dir = "data/"
variant_path = "#{build_dir}"

cookies_file = "log/cookies.txt"

$curl_opts = "--compressed -k"
# $curl_opts = "--compressed -k -v"  ## DEBUG

# pre-requisite: MDX Toolkit installed.
prep_tool_bin = "/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"
prep_tool_version = `#{prep_tool_bin}`.each_line.to_a[1].scan(/version(.*)/).flatten.first.strip

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "#{data_dir}/citrix_2015.mobileprovision"


android_utils_paths = "`pwd`/ext/apktool1.5.2:`pwd`/ext/android-sdk/build-tools/android-4.4W"



## user-interfacing tasks


task :clean do
  sh %(rm -rf build/*)
end


namespace :app do

  desc "create an .mdx from an .ipa, or .apk of an app."
  task :package, [:app_name] do |t, args|
    app = args[:app_name]

    call_task 'config:merge', app

    ipa = "#{data_dir}/apps/#{app}/#{app}.ipa"
    apk = "#{data_dir}/apps/#{app}/#{app}.apk"
  
    call_task 'ipa:make_mdx', app if File.exists? ipa
    call_task 'apk:make_mdx', app if File.exists? apk

    Dir.glob("#{build_dir}/#{app}-*.mdx").each do |mdx|
      call_task 'mdx:apply_policy_delta', mdx.sub(/\.mdx$/, '').sub(/^#{build_dir}\/*/,'')
    end
  end


  desc "create variants defined in app configuration."
  task :clone, [:app_name] => [ 
    :'config:merge', 
  ] do |t, args|
    app = args[:app_name]
    ipa = "#{data_dir}/apps/#{app}/#{app}.ipa"
    apk = "#{data_dir}/apps/#{app}/#{app}.apk"

    call_task 'config:merge_variants', args[:app_name]
  
    variants(app).each do |variant_config|

      variant_name = variant_config['id']
      variant_bundle_id = variant_config['bundle_id']
      variant_package_id = variant_config['package_id']

      raise "variant name for #{app} is same as name for original" if variant_name == app

      if variant_bundle_id
        platform = :ios

        variant_ipa_path = "#{variant_path}/#{File.basename(ipa).gsub(app, variant_name)}"
        # variant_config_path = "#{variant_path}/#{variant_name}-config.yaml"

        call_task 'ipa:clone', app, variant_name, variant_bundle_id
        call_task 'ipa:make_mdx', variant_name, variant_ipa_path

      elsif variant_package_id
        platform = :android

        variant_apk_path = "#{variant_path}/#{File.basename(apk).gsub(app, variant_name)}"

        call_task 'apk:clone', app, variant_name, variant_package_id
        call_task 'apk:make_mdx', variant_name, variant_apk_path
      else
        raise "define a unique variant id (iOS) or package_id (Android) for variant '#{variant_name}'"
      end

      call_task 'mdx:apply_policy_delta', "#{variant_name}-#{platform}", "#{app}-#{platform}" 

      puts "## packaged variant '#{variant_name}-#{platform}'"
      
    end
  end


  desc "update app controller entries for an app and all variants."
  task :deploy, [ :app_name, :targets_regexp ] do |t, args|
    app = args[:app_name]
    targets_regexp = args[:targets_regexp]   # FIXME arg validation

    targets = targets(targets_regexp)

    package_names = Dir.glob("#{build_dir}/#{app}*.mdx").map {|e| File.basename(e).sub(/\.mdx$/, '')}
    raise "no .mdx files found in #{build_dir}" if package_names.length == 0

    puts "## targeting #{targets} for packages #{package_names}"

    # for each target, call the app_controller:create task.
    targets.each do |target|

      raise "no servers defined for target '#{target['id']}'." if ! target['servers']

      package_names.each do |package|

        config_file = "#{build_dir}/#{package}-config.yaml"
        content = File.read(config_file)
        config = YAML.load content

        if target['id'] =~ /#{config['targets']}/
          target_name = target['id']
          puts "# deploy #{package} to target '#{target_name}'"

          target['servers'].each do |server|
            appc_base_url = server['base_url']
            login_json = server['credentials_path']
            
            call_task 'app_controller:crupdate', package, appc_base_url, login_json, target_name
          end

        else
          puts "# skipping #{package} as #{target} not in its scoped targets"
        end

      end  

    end
  end

end


namespace :config do

  desc "generate merged configuration using config definitions"
  task :merge, [ :app_name ] do |t, args|
    raise "task needs arguments: see 'rake -T'" if args.nil?
    app = args[:app_name]

    config = cascaded_config app

    [ :ios, :android ].each do |platform|
      # cascade platform-specific manifest_values
      platform_specific_config =
        if platform_manifest_values = config["manifest_values[#{platform}]"]
          [ 
            config, 
            {
              'manifest_values' => platform_manifest_values
            }
          ].cascaded
        else
          config
        end

      merged_config_path = "#{build_dir}/#{app}-#{platform}-config.yaml"
      File.write merged_config_path, platform_specific_config.to_yaml
      puts "# #{merged_config_path}: using #{platform_specific_config['id']}"
    end
  end

  task :merge_variants, [ :app_name ] do |t, args|
    app = args[:app_name]

    call_task 'config:merge', args[:app_name]

    config = cascaded_config app

    variants(app).each do |variant_config|
      variant_name = variant_config['id']
      platform = 
        if variant_config['bundle_id']
          :ios
        else
          :android
        end

      variant_config_path = "#{variant_path}/#{variant_name}-#{platform}-config.yaml"

      cascaded_variant_config = [ config, variant_config ].cascaded
      File.write variant_config_path, cascaded_variant_config.to_yaml
      puts "# #{variant_config_path}: config for #{variant_name}-#{platform}"
    end
  end

end



## building-block tasks

namespace :mdx do

  task :apply_policy_delta, [:app, :policy_src_app] do |t, args|
    app = args[:app]
    policy_src_app = args[:policy_src_app] || app
    source_staging_path = "#{build_dir}/#{policy_src_app}.mdx.unzipped"
    target_staging_path = "#{build_dir}/#{app}.mdx.unzipped"

    call_task 'mdx:unzip', policy_src_app
    FileUtils.cp_r source_staging_path, target_staging_path if policy_src_app != app

    # apply the policy delta and save 
    policy_xml = "#{source_staging_path}/policy_metadata.xml"
    config_path = "#{build_dir}/#{app}-config.yaml"
    config_str = File.read(config_path)
    config = YAML.load(config_str)
    policy_delta = config['manifest_values']['policies']

    policy_xml_str = File.read policy_xml
    modified_xml = policy_applied policy_xml_str, policy_delta

    File.write "#{target_staging_path}/policy_metadata.xml", modified_xml


    # config_with_dereferenced_vars = dereferenced config_str, variables(env_name)  # FIXME env_name requires another multiplexing step.
    if modified_xml =~ Pattern_variable
      puts "policy metadata contains variables; proceeding with target-specific cloning."
      
      # stage files for each matching target.
      targets_regexp = config['targets']
      targets(targets_regexp).each do |target|
        env_name = target['id']
        final_staging_path = "#{build_dir}/#{app}-#{env_name}.mdx.unzipped"

        FileUtils.cp_r target_staging_path, final_staging_path

        xml_with_dereferenced_vars = dereferenced modified_xml, variables(env_name)
        File.write "#{final_staging_path}/policy_metadata.xml", xml_with_dereferenced_vars

        call_task 'mdx:zip', "#{app}-#{env_name}"
      end
    else
      call_task 'mdx:zip', app
    end


    puts "# applied config delta #{config_path} to #{policy_xml} and repackaged mdx for #{app}"
  end

  task :unzip, [:app] do |t, args|
    sh %(
      cd #{build_dir}
      rm -rf #{args[:app]}.mdx.unzipped
      unzip -q #{args[:app]}.mdx -d #{args[:app]}.mdx.unzipped
    )
  end

  task :zip, [:app] do |t, args|
    sh %(
      cd #{build_dir}
      rm #{args[:app]}.mdx
      (cd #{args[:app]}.mdx.unzipped; zip -q -r ../#{args[:app]}.mdx .)
    )
  end
end


namespace :ipa do

  desc "clone an ipa"
  task :clone, [:app, :variant_name, :variant_bundle_id] do |t, args|
    app = args[:app]
    ipa = "#{data_dir}/apps/#{app}/#{app}.ipa"
    
    # create variant ipa.
    call_task 'ipa:rewrite_bid', ipa, args[:variant_bundle_id], args[:variant_name]
  end

  desc "rewrite original bundle id with suffixed bundle id"
  task :rewrite_bid, [:ipa, :bundle_id, :variant_name] do |t, args|
    call_task 'ipa:unzip', args[:ipa]

    app = File.basename(args[:ipa]).sub(/\.ipa$/, '')
    bundle_id = args[:bundle_id]
    variant_name = args[:variant_name]

    info_plist_path = Dir.glob("#{build_dir}/#{app}/Payload/*.app/Info.plist").to_a.first

    # convert and sub string
    sh %(
      plutil -convert json "#{info_plist_path}"      
    )
    plist_str = File.read info_plist_path
    plist_str.gsub!(/"CFBundleIdentifier":".*?"/, %("CFBundleIdentifier":"#{bundle_id}"))
    File.write info_plist_path, plist_str 

    # convert back and re-zip
    sh %(
      plutil -convert binary1 "#{info_plist_path}"      
    )
    call_task :'ipa:zip', app, variant_name
    
    puts "# rewrote bundle id for #{app} to #{bundle_id}"
  end

  task :make_mdx, [:app_name, :ipa] do |t, args|
    app_name = args[:app_name]

    ipa = args[:ipa] || "#{data_dir}/apps/#{app_name}/#{app_name}.ipa"
    raise "no ipa at #{ipa}" unless File.exist? ipa
    
    mdx = "#{build_dir}/#{app_name}-ios.mdx"

    description = "XenMobile-treated app. PrepTool version:#{prep_tool_version} timestamp:#{Time.new.utc.to_s}"

    ## preptool information.
    # Usage: CGAppCLPrepTool [ Wrap |Sign |SetInfo |GetInfo ] -Cert CERTIFICATE -Profile PROFILE -in INPUTFILE -out OUTPUTFILE -appDesc DESCRIPTION -logFile LOGFILE -logWriteLevel LEVEL -logDisplayLevel LEVEL

    #  -Cert CERTIFICATE          ==>  (Required)Name of the certificate to sign the app with
    #  -Profile PROFILE           ==>  (Required)Name of the provisioning profile to sign the app with
    #  -in INPUTFILE              ==>  (Required)Name of the input app file
    #  -out OUTPUTFILE            ==>  (Required)Name of the output mdx file
    #  -appName  NAME             ==>  (Optional)Friendly name of the app 
    #  -appDesc DESCRIPTION       ==>  (Optional)Description of the package 
    #  -minPlatform  VERSION      ==>  (Optional)Minimum supported platform version 
    #  -maxPlatform  VERSION      ==>  (Optional)Maximum supported platform version 
    #  -excludedDevices DEVICES   ==>  (Optional)A list of device type the App is not allowed to run 
    #  -logFile LOGFILE           ==>  (Optional)Name of the log file 
    #  -logWriteLevel 0-4         ==>  (Optional)Log level for file 
    #  -logDisplayLevel 0-4       ==>  (Optional)Log level for standard output 
    #  -appMode 1-2               ==>  (Optional)1:MDX Specific 2:General Apple App store 
    #  -sdk yes/no                ==>  (Optional)yes/no 
    #  -storeURL url              ==>  (Optional)http://appstoreaddress/adHoc/ThriftClientTest.plist 
    #  -update yes/no             ==>  (Optional)yes/no 
    #  -policyXML FILE PATH       ==>  (Optional)app specific policy file.
    ##

    sh %(
      #{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}"  -appName "#{app_name}-ios" -appDesc "#{description}" -logFile "#{log_dir}/#{app_name}-ios-mdx-verbose.log" -logWriteLevel "4" &> "#{log_dir}/#{app_name}-ios-mdx.log"
    )

    puts "# packaged #{mdx} from #{ipa}"
  end

  task :unzip, [:ipa] do |t, args|
    ipa = args[:ipa]
    unzip_dir = "#{build_dir}/#{File.basename(ipa).sub(/\.ipa$/, '')}"
    rm_rf "#{unzip_dir}"
    sh %(
      unzip -q #{ipa} -d "#{unzip_dir}" > /dev/null
    )
  end

  task :zip, [:app_name, :ipa_name] do |t, args|
    app = args[:app_name]
    ipa_name = args[:ipa_name]
    sh %(
      (rm "#{build_dir}/#{app}.ipa"; cd "#{build_dir}/#{app}" && zip -q -r ../#{ipa_name}.ipa . > /dev/null)
    )
  end

end


namespace :apk do
  desc "clone an apk"
  task :clone, [:app, :variant_name, :package_id] do |t, args|
    app = args[:app]
    package_id = args[:package_id]
    variant_name = args[:variant_name]

    original_package_id = variants(app).find{|e| e['id'] == variant_name}['package_id'] || (raise "package_id not defined in config for #{app}")

    sh %(
      export PATH="#{android_utils_paths}:$PATH"
      cd #{build_dir}
      
      rm -rf #{app}
      apktool d ../#{data_dir}/apps/#{app}/#{app}.apk  # decompile
    )

    matching_files = `grep -rl '#{original_package_id}' #{build_dir}/#{app}`.each_line.to_a
    matching_files.each do |file|
      file.strip!
      content = File.read(file)
      File.write file, content.gsub(original_package_id, package_id)
    end

    puts "replaced package id with #{package_id}
    "
    sh %(
      export PATH="#{android_utils_paths}:$PATH"
      cd #{build_dir}

      apktool b #{app} #{variant_name}.apk  # archive into .apk
    )

    puts "# rewrote package id for #{app} to #{package_id}"
  end

  task :make_mdx, [:app_name, :apk] do |t, args|
    app_name = args[:app_name]
    apk = args[:apk] || "#{data_dir}/apps/#{app_name}/#{app_name}.apk"

    mdx = "#{build_dir}/#{app_name}-android.mdx"

    description = "XenMobile-treated app. PrepTool version:#{prep_tool_version} timestamp:#{Time.new.utc.to_s}"

    # ANDROID
    # commands:
    # export PATH="$PATH":/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/build-tools/android-4.4W:/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/platform-tools:/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/tools

    sh %(
      export PATH="#{android_utils_paths}:$PATH"

      java -jar /Applications/Citrix/MDXToolkit/ManagedAppUtility.jar wrap -in #{apk} -out #{mdx} -appName "#{app_name}-android" -appDesc "#{description}" -keystore #{data_dir}/my.keystore -storepass android -keyalias wrapkey -keypass android > "#{log_dir}/#{app_name}-android-mdx.log"
    )

    puts "# packaged #{mdx}"
  end
end


namespace :app_controller do
  desc "create or update app entry in app controller"
  task :crupdate, [:app_name, :appc_base_url, :login_json, :env_name] => [:login] do |t, args|
    # a primitive implementation.
    call_task 'app_controller:create', args[:app_name], args[:appc_base_url], args[:login_json], args[:env_name]
    call_task 'app_controller:update', args[:app_name], args[:appc_base_url], args[:login_json], args[:env_name]
  end

  desc "update app entry in app controller"
  task :update, [:app_name, :appc_base_url, :login_json, :env_name] => [:login] do |t, args|
    appc_base_url = args[:appc_base_url]
    app = args[:app_name]
    env_name = args[:env_name]

    mdx = "#{build_dir}/#{app}.mdx"
    manifest_json = "log/#{app}-manifest.json"
    modified_manifest_json = "log/#{app}-manifest-modified.json"

    raise "no mdx at #{mdx}" unless File.exist? mdx

    # get app id
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/application?_=1406621245975 #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" > log/app_controller_entries.log
    )
    entries_json = JSON.parse(`cat log/app_controller_entries.log`)
    app_id = id_for_app app, entries_json

    # upload binary
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/upload?CG_CSRFTOKEN=#{$csrf_token_header.gsub('CG_CSRFTOKEN: ', '')} #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --form "data=@#{mdx};type=application/octet-stream"
    )

    # fetch manifest and save for the next request.
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgradepkg/#{app_id} #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data "#{app}.mdx"  > #{manifest_json}
    )
    # prettify.
    File.write manifest_json, JSON.pretty_generate(JSON.parse(File.read(manifest_json)))


    # # apply delta to the manifest, save.
    # config_delta_path = "#{build_dir}/#{app}-config.yaml"
    # config_delta = YAML.load File.read(config_delta_path)
    # delta_applied = JSON.parse(File.read(manifest_json))
    # if config_delta['manifest_values']
    #   puts "# applying config delta '#{config_delta['id']}' for #{app} from #{config_delta_path}"
    #   delta_applied = delta_applied delta_applied, config_delta['manifest_values']
    # end

    # modified_json_str = dereferenced JSON.pretty_generate(delta_applied), variables(env_name)
    # File.write modified_manifest_json, modified_json_str

    # SUPERCEDED by policy delta application in mdx. we may need this back in the future when users self-service the full deployment process.
    modified_manifest_json = manifest_json

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers(appc_base_url)} #{$curl_opts} -H "#{$cookies_as_headers}" -H "Content-Type: application/json;charset=UTF-8" -H "#{$csrf_token_header}" --data "@#{modified_manifest_json}"
    )

    puts "## updated app controller entry for #{app}"
  end


  desc "create app entry in app controller"
  task :create, [:app_name, :appc_base_url, :login_json, :env_name] => :login do |t, args|
    puts args
    app_name = args[:app_name]
    appc_base_url = args[:appc_base_url]
    mdx = "#{build_dir}/#{app_name}.mdx"

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/api/v1/mobileApp #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data-binary "@#{mdx}" -H "Content-type: application/octet-stream"
    )

    # the 'create' endpoint doesn't properly set metadata, so immediately invoke an update.
    call_task 'app_controller:update', app_name, appc_base_url, args[:login_json], args[:env_name]
  end

  desc "get metadata for app entry"
  task :get_metadata, [:app_name, :appc_base_url, :login_json] => :login do |t, args|
    metadata_path = "#{build_dir}/#{args[:app_name]}-metadata.json"
    appc_base_url = args[:appc_base_url]

    app_id = id_for_app args[:app_name], JSON.parse(`cat log/app_controller_entries.log`)
    
    metadata = metadata_for_app_id app_id, appc_base_url, headers, cookies_file
    File.write metadata_path, metadata

    puts "metadata saved to #{metadata_path}"
  end


  task :login, [:appc_base_url, :login_json] do |t, args|
    appc_base_url = args[:appc_base_url]
    login_json = args[:login_json]
    raise "nil parameter(s) to task :login; args: #{args}" unless appc_base_url && login_json

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/ #{headers(appc_base_url)} #{$curl_opts} -I --cookie-jar #{cookies_file}
    )

    cookies_a = `cat #{cookies_file}`.each_line.map{|e| e.split("\t")}.map{|e| e[5..6]}.compact
    cookies_a << ['OCAJSESSIONID', '(null)']
    $cookies_as_headers = "Cookie: " + cookies_a.map{|k,v| "#{k}=#{v.strip}"}.join("; ")

    $csrf_token_header=`/usr/bin/curl #{appc_base_url}/ControlPoint/JavaScriptServlet -X POST #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "FETCH-CSRF-TOKEN: 1"`.gsub(":", ": ")

    sh %( 
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/newlogin #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8" --data "@#{login_json}"
    )
    puts "# login complete."
  end


  namespace :config do
    task :get, [:appc_base_url, :login_json] => :login do |t, args|
      appc_base_url = args[:appc_base_url]
      sh %(
        /usr/bin/curl #{appc_base_url}/ControlPoint/rest/release/snapshot?_=1409057781201 #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" > log/snapshot.bin

      )
    end
  end
  
  ## util

  def id_for_app(app, entries_json)
    apps_by_id = Hash[ entries_json['ncgapplication'].map{|e| [ e['name'], e['applicationlabel'] ]} ]
    puts apps_by_id

    matching_entries = apps_by_id.select{|k,v| v == app}
    if matching_entries.size != 1
      raise "expected 1 entry matching '#{app}' but got: #{matching_entries}"
    end

    app_id = matching_entries.keys.first
  end

  def metadata_for_app_id(app_id, appc_base_url, headers, cookies_file)
    metadata = `
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/#{app_id}?_=1406733010550 #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8"
    `
  end

  def headers(appc_base_url)
    %(
      -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: #{appc_base_url}/ControlPoint/" -H "Origin: #{appc_base_url}" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"
    ).strip
  end

end



def call_task task_name, *args
  Rake::Task[task_name].reenable
  Rake::Task[task_name].invoke *args
end



