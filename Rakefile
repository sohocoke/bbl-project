require 'json'
require 'rake/packagetask'
require_relative 'lib/configs'

# FIXME: make all curl -v output go to stdout.
# TODO: capture all shell execution output, do some sanity checks for errors. (grep 'HTTP/1.1')
# TODO: extract params.


## run-specific params
app = "MVCNetworking"
ipa = "data/#{app}.ipa"

## env
log_path = "log/"
mdx = "dist/#{app}.mdx"
manifest_json = "log/#{app}_manifest.json"
cookies_file = "data/cookies.txt"

appc_base_url = "https://161.202.193.123:4443"

# curl_opts = "--compressed -k -v"  ## DEBUG
curl_opts = "--compressed -k"

# pre-requisite: MDX Toolkit installed.
prep_tool_bin = "/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "data/citrix_2014.mobileprovision"



## user-interfacing tasks

namespace :app do
  desc "TODO unzip ipa, rewrite info.plist with new bundle id, rezip ipa."
  task :clone => [ :'ipa:unzip', :'ipa:rewrite_bid', :'ipa:zip' ]


  desc "TODO wrap with mdx, unzip mdx, rewrite policy, rezip mdx, update app controller entry."
  # task :deploy, [ :app_name ] => [ :'config:merge', :'mdx:create', :'mdx:unzip', :'mdx:rewrite_policy', :'mdx:zip' ]
  task :deploy, [ :app_name ] => [ :'config:merge', :'mdx:create', :'config:deploy' ]
end

namespace :config do
  desc "generate merged configuration using config definitions"
  task :merge, [ :app_name ] do |t, args|
    raise "task needs arguments: see 'rake -T'" if args.nil?
    puts cascaded_configs args[:app_name]
  end

  # loop through all targets and deploy.
  task :deploy, [:app_name] => :merge do |t, args|
    targets.each do |target|
      puts "### deploy to target '#{target['id']}'"
      target['servers'].each do |server|
        appc_base_url = server['base_url']
        login_json = server['credentials_path']
        
        # invoke app_controller:update
        Rake::Task['app_controller:update'].invoke appc_base_url, login_json
      end
    end  
  end
end

namespace :mdx do
  desc "create an .mdx from an .ipa"
  task :create do

    prep_tool_version = `#{prep_tool_bin}`.each_line.to_a[1].scan(/version(.*)/).flatten.first

    description = "XenMobile-treated app (date=#{Time.new}, version=#{prep_tool_version})"

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

    sh %(
      #{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_path}/#{app}-mdx.log" -logWriteLevel "4" -appName "#{app}" -appDesc "#{description}"
    )
  end

  task :unzip do
    sh %(
      unzip #{mdx} -d "mdx-unzipped"
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
  headers = %(
    -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: #{appc_base_url}/ControlPoint/" -H "Origin: #{appc_base_url}" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"
    ).strip

  desc "update app entry in app controller"
  task :update, [:appc_base_url, :login_json] => :login do
    # get app id
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/application?_=1406621245975 #{headers} #{curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" > log/app_controller_entries.log
    )
    entries_json = JSON.parse(`cat log/app_controller_entries.log`)
    app_id = id_for_app app, entries_json


    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/upload?CG_CSRFTOKEN=#{$csrf_token_header.gsub('CG_CSRFTOKEN: ', '')} #{headers} #{curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --form "data=@#{mdx};type=application/octet-stream"
    )
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgradepkg/#{app_id} #{headers} #{curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" --data "#{app}.mdx"  > #{manifest_json}  # save for the next request.
    )

    # TODO some fields, including ones specified during prep tool invocation, do not apply -- select and replace values for the right object paths.
    # e.g. description
    


    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers} #{curl_opts} -H "#{$cookies_as_headers}" -H "Content-Type: application/json;charset=UTF-8" -H "#{$csrf_token_header}" --data "@#{manifest_json}"
    )
  end

  desc "TODO create app entry in app controller"
  task :create => :login do
  end

  desc "get manifest for app entry"
  task :get_manifest, [:app_name] => :login do |t, args|
    app_id = id_for_app args[:app_name], JSON.parse(`cat log/app_controller_entries.log`)
    
    metadata = metadata_for_app_id app_id, appc_base_url, headers, cookies_file
    puts metadata
  end


  task :login, [:appc_base_url, :login_json] do |t, args|
    appc_base_url = args[:appc_base_url]
    login_json = args[:login_json]
    raise "nil parameter(s) to task :login; args: #{args}" if ! args.select(&:nil?).empty?

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/ #{headers} #{curl_opts} -I --cookie-jar #{cookies_file}
    )

    cookies_a = `cat #{cookies_file}`.each_line.map{|e| e.split("\t")}.map{|e| e[5..6]}.compact
    cookies_a << ['OCAJSESSIONID', '(null)']
    $cookies_as_headers = "Cookie: " + cookies_a.map{|k,v| "#{k}=#{v.strip}"}.join("; ")

    $csrf_token_header=`/usr/bin/curl #{appc_base_url}/ControlPoint/JavaScriptServlet -X POST #{headers} #{curl_opts} --cookie #{cookies_file} -H "FETCH-CSRF-TOKEN: 1"`.gsub(":", ": ")

    sh %( 
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/newlogin #{headers} #{curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8" --data "@#{login_json}"
    )
    puts "### login complete."
  end



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
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/#{app_id}?_=1406733010550 #{headers} #{curl_opts} --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8"
    `
  end
end


namespace :ipa do
  task :rewrite_bid do
    # TODO rewrite original bundle id with suffixed bundle id.
  end

  task :unzip do
    sh %(
      unzip #{ipa} -d "ipa-unzipped"
    )
  end

  task :zip do
    sh %(
      (cd ipa-unzipped && zip -r ../ipa-rezipped.zip .)
    )
  end
end



