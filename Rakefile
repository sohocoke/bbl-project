require 'json'
require 'xml'
require 'rake/packagetask'
require_relative 'lib/configs'

# FIXME: make all curl -v output go to stdout.
# TODO: capture all shell execution output, do some sanity checks for errors. (grep 'HTTP/1.1')
# TODO: parameterise arguments related to android signing.


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

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "#{data_dir}/citrix_2014.mobileprovision"


android_utils_paths = "~/Downloads/apktool1.5.2:~/.bin:/Users/andy/Applications/development apps/Android Studio.app/sdk/build-tools/android-4.4W:/Users/andy/Applications/development apps/Android Studio.app/sdk/platform-tools:/Users/andy/Applications/development apps/Android Studio.app/sdk/tools"



## user-interfacing tasks


task :clean do
  sh %(rm -rf build/*)
end


namespace :app do

  desc "create an .mdx from an .ipa, or .apk of an app"
  task :package, [:app_name] do |t, args|
    call_task 'ipa:make_mdx', args[:app_name]
  end


  # pre-requisite: prototype mdx has been packaged.
  desc "unzip ipa, rewrite info.plist with new bundle id, rezip ipa."
  task :clone, [:app_name] => [ 
    :'config:merge', 
  ] do |t, args|
    app = args[:app_name]
    ipa = "#{data_dir}/apps/#{app}/#{app}.ipa"
    apk = "#{data_dir}/apps/#{app}/#{app}.apk"
  
    variants(app).each do |variant_spec|
      variant_name = variant_spec['id']
      variant_bundle_id = variant_spec['bundle_id']
      variant_package_id = variant_spec['package_id']

      raise "variant name for #{app} is same as name for original" if variant_name == app

      if variant_bundle_id
        # ios
        variant_ipa_path = "#{variant_path}/#{File.basename(ipa).gsub(app, variant_name)}"
        # variant_config_path = "#{variant_path}/#{variant_name}-config.yaml"

        ## ios
        call_task 'ipa:clone', app, variant_bundle_id, variant_name
        call_task 'ipa:make_mdx', variant_name, variant_ipa_path
      elsif variant_package_id
        variant_apk_path = "#{variant_path}/#{File.basename(apk).gsub(app, variant_name)}"

        call_task 'apk:clone', app, variant_package_id, variant_name
        call_task 'apk:make_mdx', variant_name, variant_apk_path
      else
        raise "define a unique variant id (iOS) or package_id (Android) for variant '#{variant_name}'"
      end

      
      call_task 'mdx:replace_policy', variant_name, app

      puts "packaged variant '#{variant_name}'"


      ## android TODO

      # call_task 'apk:clone'
      # call_task 'ipa:make_mdx', variant_name, variant_ipa_path  # TODO decouple from ios
      # call_task 'mdx:replace_policy', variant_name, app

      # puts "packaged variant '#{variant_name}'"
      
      
    end
  end


  desc "update app controller entries for an app and all variants."
  task :deploy, [ :app_name, :targets_regexp ] do |t, args|
    app = args[:app_name]
    targets_regexp = args[:targets_regexp]   # FIXME arg validation

    targets = targets(targets_regexp)

    package_names = Dir.glob("#{build_dir}/#{app}*.mdx").map {|e| File.basename(e).sub(/\.mdx$/, '')}

    puts "## targeting #{targets}"

    targets.each do |target|

      raise "no servers defined for target '#{target['id']}'." if ! target['servers']

      # call_task 'config:deploy', package
      package_names.each do |package|

        config = YAML.load File.read("#{build_dir}/#{package}-config.yaml")
        if target['id'] =~ /#{config['targets']}/

          puts "# deploy #{package} to target '#{target['id']}'"

          target['servers'].each do |server|
            appc_base_url = server['base_url']
            login_json = server['credentials_path']
            
            call_task 'app_controller:create', package, appc_base_url, login_json
            # call_task 'app_controller:update', package, appc_base_url, login_json
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

    merged_config_path = "#{build_dir}/#{app}-config.yaml"
    File.write merged_config_path, config.to_yaml
    puts "wrote #{config['id']} to #{merged_config_path}"

    # variants
    variants(app).each do |variant_config|
      variant_name = variant_config['id']
      variant_config_path = "#{variant_path}/#{variant_name}-config.yaml"

      cascaded_variant_config = [ config, variant_config ].cascaded
      File.write variant_config_path, cascaded_variant_config.to_yaml
      puts "wrote config for variant #{variant_name}"
    end
  end

end



## building-block tasks

namespace :mdx do

  task :replace_policy, [:variant_name, :app_name] do |t, args|
    sh %(
      cd "#{build_dir}"

      rm -rf #{args[:app_name]}.mdx.unzipped #{args[:variant_name]}.mdx.unzipped

      unzip #{args[:app_name]}.mdx -d #{args[:app_name]}.mdx.unzipped
      unzip #{args[:variant_name]}.mdx -d #{args[:variant_name]}.mdx.unzipped
      
      cp #{args[:app_name]}.mdx.unzipped/policy_metadata.xml #{args[:variant_name]}.mdx.unzipped/
      
      rm #{args[:variant_name]}.mdx
      (cd #{args[:variant_name]}.mdx.unzipped; zip -r ../#{args[:variant_name]}.mdx .)
    )

    puts "replaced policy file in #{args[:variant_name]} with one in #{args[:app_name]}"
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
    
    puts "rewrote bundle id for #{app} to #{bundle_id}"
  end

  task :make_mdx, [:app_name, :ipa] do |t, args|
    app_name = args[:app_name]

    ipa = args[:ipa] || "#{data_dir}/apps/#{app_name}/#{app_name}.ipa"
    raise "no ipa at #{ipa}" unless File.exist? ipa
    
    mdx = "#{build_dir}/#{app_name}.mdx"

    prep_tool_version = `#{prep_tool_bin}`.each_line.to_a[1].scan(/version(.*)/).flatten.first

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
      #{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_dir}/#{app_name}-mdx.log" -logWriteLevel "4" -appName "#{app_name}" -appDesc "#{description}"
    )

    puts "packaged #{mdx} from #{ipa}"
  end

  task :unzip, [:ipa] do |t, args|
    ipa = args[:ipa]
    unzip_dir = "#{build_dir}/#{File.basename(ipa).sub(/\.ipa$/, '')}"
    rm_rf "#{unzip_dir}"
    sh %(
      unzip #{ipa} -d "#{unzip_dir}"
    )
  end

  task :zip, [:app_name, :ipa_name] do |t, args|
    app = args[:app_name]
    ipa_name = args[:ipa_name]
    sh %(
      (rm "#{build_dir}/#{app}.ipa"; cd "#{build_dir}/#{app}" && zip -r ../#{ipa_name}.ipa .)
    )
  end

end


namespace :apk do
  desc "clone an apk"
  task :clone, [:app, :package_id, :variant_name] do |t, args|
    app = args[:app]
    package_id = args[:package_id]
    variant_name = args[:variant_name]

    sh %(
      export PATH="#{android_utils_paths}:$PATH"
      cd build
      
      rm -rf #{app}
      apktool d ../#{data_dir}/apps/#{app}/#{app}.apk  # decompile
    )

    # edit package id
    doc = XML::Parser.file("#{build_dir}/#{app}/AndroidManifest.xml").parse
    a = doc.root.attributes.get_attribute('package')
    a.value = package_id
    doc.save "#{build_dir}/#{app}/AndroidManifest.xml"

    sh %(
      export PATH="#{android_utils_paths}:$PATH"
      cd #{build_dir}

      apktool b #{app} #{variant_name}.apk  # archive into .apk
    )

    puts "rewrote package id for #{app} to #{package_id}"
  end

  task :make_mdx, [:app_name, :apk] do |t, args|
    app_name = args[:app_name]
    apk = args[:apk] || "#{data_dir}/apps/#{app_name}/#{app_name}.apk"

    mdx = "#{build_dir}/#{app_name}-android.mdx"

    # ANDROID
    # commands:
    # export PATH="$PATH":/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/build-tools/android-4.4W:/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/platform-tools:/Users/andy/Applications/development\ apps/Android\ Studio.app/sdk/tools

    sh %(
      export PATH="#{android_utils_paths}:$PATH"

      java -jar /Applications/Citrix/MDXToolkit/ManagedAppUtility.jar wrap -in #{apk} -out build/#{mdx} -keystore #{data_dir}/my.keystore -storepass android -keyalias wrapkey -keypass android
    )
  end
end


namespace :app_controller do

  desc "update app entry in app controller"
  task :update, [:app_name, :appc_base_url, :login_json] => [ :'config:merge', :login] do |t, args|
    appc_base_url = args[:appc_base_url]
    app = args[:app_name]
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


    # apply delta to the manifest, save.
    config_delta_path = "#{build_dir}/#{app}-config.yaml"
    config_delta = YAML.load File.read(config_delta_path)
    delta_applied = JSON.parse(File.read(manifest_json))
    if config_delta['manifest_values']
      puts "# applying config delta '#{config_delta['id']}' for #{app} from #{config_delta_path}"
      delta_applied = delta_applied delta_applied, config_delta['manifest_values']
    end

    modified_json_str = dereferenced JSON.pretty_generate(delta_applied), variables
    File.write modified_manifest_json, modified_json_str

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers(appc_base_url)} #{$curl_opts} -H "#{$cookies_as_headers}" -H "Content-Type: application/json;charset=UTF-8" -H "#{$csrf_token_header}" --data "@#{modified_manifest_json}"
    )

    puts "## updated app controller entry for #{app}"
  end


  desc "create app entry in app controller"
  task :create, [:app_name, :appc_base_url, :login_json] => :login do |t, args|
    puts args
    app_name = args[:app_name]
    appc_base_url = args[:appc_base_url]
    mdx = "#{build_dir}/#{app_name}.mdx"

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/api/v1/mobileApp #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data-binary "@#{mdx}" -H "Content-type: application/octet-stream"
    )

    # the 'create' endpoint doesn't properly set metadata, so immediately invoke an update.

    call_task 'app_controller:update', app_name, appc_base_url, args[:login_json]
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


  ## util

  def id_for_app(app, entries_json)
    apps_by_id = Hash[ entries_json['ncgapplication'].map{|e| [ e['name'], e['applicationlabel'] ]} ]
    puts apps_by_id

    matching_entries = apps_by_id.select{|k,v| v == app}
    if matching_entries.size != 1
      raise "matching entries for app '#{app}': #{matching_entries}"
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



