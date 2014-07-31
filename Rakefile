require 'json'
require 'rake/packagetask'


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
login_json = "data/login.json"

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
  task :deploy => [ :'mdx:create', :'mdx:unzip', :'rewrite_policy', :'mdx:zip' ]
end



namespace :mdx do
  desc "create an .mdx from an .ipa"
  task :create do
    sh %(
      #{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_path}/#{app}-mdx.log" -logWriteLevel "4" -appName "#{app}"
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
  task :update => :login do
    # get app id
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/application?_=1406621245975 #{headers} --compressed -k --cookie #{cookies_file} -H "#{$csrf_token_header}" -v > log/app_controller_entries.log
    )
    entries_json = JSON.parse(`cat log/app_controller_entries.log`)
    app_id = id_for_app app, entries_json


    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/upload?CG_CSRFTOKEN=#{$csrf_token_header.gsub('CG_CSRFTOKEN: ', '')} #{headers} --compressed -k --cookie #{cookies_file} -H "#{$csrf_token_header}" --form "data=@#{mdx};type=application/octet-stream" -v
    )
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgradepkg/#{app_id} #{headers} --compressed -k --cookie #{cookies_file} -H "#{$csrf_token_header}" --data "#{app}.mdx" -v  > #{manifest_json}  # save for the next request.
    )

    # TODO apply all diffs in original package, or something.

    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers} --compressed -k -H "#{$cookies_as_headers}" -H "Content-Type: application/json;charset=UTF-8" -H "#{$csrf_token_header}" --data "@#{manifest_json}" -v
    )
  end

  desc "TODO create app entry in app controller"
  task :create => :login do
  end


  task :login do
    sh %(
      /usr/bin/curl #{appc_base_url}/ControlPoint/ #{headers} --compressed -k -I --cookie-jar #{cookies_file} -v
    )

    cookies_a = `cat #{cookies_file}`.each_line.map{|e| e.split("\t")}.map{|e| e[5..6]}.compact
    cookies_a << ['OCAJSESSIONID', '(null)']
    $cookies_as_headers = "Cookie: " + cookies_a.map{|k,v| "#{k}=#{v.strip}"}.join("; ")

    $csrf_token_header=`/usr/bin/curl #{appc_base_url}/ControlPoint/JavaScriptServlet -X POST #{headers} --compressed -k --cookie #{cookies_file} -H "FETCH-CSRF-TOKEN: 1"`.gsub(":", ": ")

    sh %( 
      /usr/bin/curl #{appc_base_url}/ControlPoint/rest/newlogin #{headers} --compressed -k --cookie #{cookies_file} -H "#{$csrf_token_header}" -H "Content-Type: application/json;charset=UTF-8" --data "@#{login_json}" -v
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



