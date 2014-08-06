require 'json'
require 'rake/packagetask'
require_relative 'lib/configs'

# FIXME: make all curl -v output go to stdout.
# TODO: capture all shell execution output, do some sanity checks for errors. (grep 'HTTP/1.1')
# TODO: extract params.


## env

log_path = "log/"
build_path = "build/"

cookies_file = "log/cookies.txt"

$curl_opts = "--compressed -k"
# $curl_opts = "--compressed -k -v"  ## DEBUG

# pre-requisite: MDX Toolkit installed.
prep_tool_bin = "/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "data/citrix_2014.mobileprovision"



## user-interfacing tasks

namespace :app do
  # pre-requisite: prototype mdx has been packaged.
  desc "unzip ipa, rewrite info.plist with new bundle id, rezip ipa."
  # task :clone => [ :'ipa:unzip', :'ipa:rewrite_bid', :'ipa:zip' ]
  task :clone, [:app_name] => [ 
    :'config:merge', 
  ] do |t, args|
    app = args[:app_name]
    ipa = "data/apps/#{app}/#{app}.ipa"
  
    configs = YAML.load File.read("#{build_path}/#{app}-config.yaml")
    configs['variants'].each do |variant_spec|
      variant_name = variant_spec['id']
      variant_path = "#{build_path}"
      variant_ipa_path = "#{variant_path}/#{File.basename(ipa).gsub(app, variant_name)}"
      variant_config_path = "#{variant_path}/#{variant_name}-config.yaml"
      variant_bundle_id = variant_spec['bundle_id']

      # TODO copy original.

      # write the variant config.
      File.write variant_config_path, variant_spec.to_yaml
      
      # create variant ipa.
      Rake::Task['ipa:rewrite_bid'].invoke ipa, variant_bundle_id

      # create variant mdx.
      Rake::Task['mdx:create'].reenable
      Rake::Task['mdx:create'].invoke app, variant_name

      # replace policy_metadata.xml in variant mdx with the one in original mdx. TODO
      # unzip, copy xml, zip

      puts "packaged variant '#{variant_name}'"
    end
  end


  desc "TODO wrap with mdx, unzip mdx, rewrite policy, rezip mdx, update app controller entry."
  # task :deploy, [ :app_name ] => [ :'config:merge', :'mdx:create', :'mdx:unzip', :'mdx:rewrite_policy', :'mdx:zip' ]
  task :deploy, [ :app_name ] do |t, args|
    [ :'config:merge', 
      :'mdx:create', 
      :'config:deploy' 
    ].each do |task_name|
      Rake::Task[task_name].invoke args[:app_name]
    end
  end
end

namespace :config do

  desc "generate merged configuration using config definitions"
  task :merge, [ :app_name ] do |t, args|
    raise "task needs arguments: see 'rake -T'" if args.nil?
    app = args[:app_name]

    configs = cascaded_configs app

    merged_config_path = "#{build_path}/#{app}-config.yaml"
    File.write merged_config_path, configs.to_yaml
    puts "wrote #{configs['id']} to #{merged_config_path}"
  end

   desc "loop through all targets and deploy."
  task :deploy, [:app_name] => :merge do |t, args|
    targets.each do |target|
      puts "### deploy to target '#{target['id']}'"
      if servers = target['servers']
        servers.each do |server|
          appc_base_url = server['base_url']
          login_json = server['credentials_path']
          
          # invoke app_controller:update
          Rake::Task['app_controller:update'].invoke appc_base_url, login_json, args[:app_name]
        end
      else
        puts "no servers defined for target '#{target['id']}'."
      end
    end  
  end
end


## building-block tasks

namespace :mdx do
  desc "create an .mdx from an .ipa"
  task :create, [:app_name, :variant_name] do |t, args|
    app_name = args[:app_name]
    variant_name = args[:variant_name] || app_name

    ipa = "data/apps/#{app_name}/#{app_name}.ipa"
    raise "no ipa at #{ipa}" unless File.exist? ipa
    
    mdx = "#{build_path}/#{variant_name}.mdx"

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
      #{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_path}/#{variant_name}-mdx.log" -logWriteLevel "4" -appName "#{variant_name}" -appDesc "#{description}"
    )

    puts "packaged #{mdx} from #{ipa}"
  end

  task :unzip, [:app_name] do |t, args|
    mdx = "#{build_path}/#{args[:app_name]}.mdx"
    sh %(
      rm -r #{build_path}/mdx-unzipped
      unzip #{mdx} -d "#{build_path}/mdx-unzipped"
    )
  end

  # NOTE re-written policy does not apply unless submitted using the 'mobileappmgmt/upgrade' endpoint in the 'update-appc-entry' sequence.
  task :rewrite_policy do
    sh %(
      # TODO add XenMobile policies since they won't be detected due to bundle id change.
    )
  end

  task :clean do
    sh %(
      rm mdx-rezipped.zip
    )
  end

  task :zip do
    sh %(
      (cd mdx-unzipped && zip -r ../mdx-rezipped.zip .)
    )
  end

end


namespace :app_controller do
  desc "update app entry in app controller"
  task :update, [:appc_base_url, :login_json, :app_name] => [ :'config:merge', :login] do |t, args|
    appc_base_url = args[:appc_base_url]
    app = args[:app_name]
    mdx = "#{build_path}/#{app}.mdx"
    manifest_json = "log/#{app}-manifest.json"
    modified_manifest_json = "log/#{app}-manifest-modified.json"

    raise "no mdx at #{mdx}" unless File.exist? mdx

    # get app id
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/application?_=1406621245975 #{headers} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" > log/app_controller_entries.log
    )
    entries_json = JSON.parse(`cat log/app_controller_entries.log`)
    app_id = id_for_app app, entries_json

    # upload binary
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/upload?CG_CSRFTOKEN=#{$csrf_token_header.gsub('CG_CSRFTOKEN: ', '')} #{headers} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --form "data=@#{mdx};type=application/octet-stream"
    )

    # fetch manifest and save for the next request.
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgradepkg/#{app_id} #{headers} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data "#{app}.mdx"  > #{manifest_json}
    )
    # prettify.
    File.write manifest_json, JSON.pretty_generate(JSON.parse(File.read(manifest_json)))


    # apply delta to the manifest, save.
    config_delta = YAML.load "#{build_path}/#{app}-config.yaml"
    puts "applying config delta '#{config_delta['id']}' for #{app}"
    delta_applied = delta_applied JSON.parse(File.read(manifest_json)), config_delta['manifest_values']
    modified_json_str = dereferenced JSON.pretty_generate(delta_applied), config_delta['variables']
    File.write modified_manifest_json, modified_json_str

    puts "updating config for #{app}"
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers} #{$curl_opts} -H "#{$cookies_as_headers}" -H "Content-Type: application/json;charset=UTF-8" -H "#{$csrf_token_header}" --data "@#{modified_manifest_json}"
    )
  end


  # FIXME doesn't set metadata: use app_controller:update immediately after.
  desc "create app entry in app controller"
  task :create, [:app_name, :appc_base_url, :login_json] => :login do |t, args|
    puts args
    app_name = args[:app_name]
    appc_base_url = args[:appc_base_url]
    mdx = "#{build_path}/#{app_name}.mdx"

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/api/v1/mobileApp #{headers(appc_base_url)} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data-binary "@#{mdx}" -H "Content-type: application/octet-stream"
    )  
  end

  desc "get metadata for app entry"
  task :get_metadata, [:app_name, :appc_base_url, :login_json] => :login do |t, args|
    metadata_path = "#{build_path}/#{args[:app_name]}-metadata.json"
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
    puts "### login complete."
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
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/#{app_id}?_=1406733010550 #{headers} #{$curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8"
    `
  end

  def headers(appc_base_url)
  %(
    -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: #{appc_base_url}/ControlPoint/" -H "Origin: #{appc_base_url}" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"
    ).strip
  end

end



namespace :ipa do

  desc "rewrite original bundle id with suffixed bundle id"

  task :rewrite_bid, [:ipa, :bundle_id] => [:unzip] do |t, args|
    app = File.basename(args[:ipa]).sub(/\.ipa$/, '')
    bundle_id = args[:bundle_id]
    info_plist_path = "#{build_path}/#{app}//Payload/#{app}.app/Info.plist"

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
    Rake::Task[:'ipa:zip'].invoke app
    
    puts "rewrote bundle id for #{app} to #{bundle_id}"
  end


  task :unzip, [:ipa] do |t, args|
    ipa = args[:ipa]
    unzip_path = "#{build_path}/#{File.basename(ipa).sub(/\.ipa$/, '')}"
    rm_rf "#{unzip_path}"
    sh %(
      unzip #{ipa} -d "#{unzip_path}"
    )
  end


  task :zip, [:app_name] do |t, args|
    app = args[:app_name]
    sh %(
      (rm "#{build_path}/#{app}.ipa"; cd "#{build_path}/#{app}" && zip -r ../#{app}.ipa .)
    )
  end

end



