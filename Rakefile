require 'rake/packagetask'


# TODO: capture all shell execution output, do some sanity checks for errors. (grep 'HTTP/1.1')


## run-specific params
app = "MVCNetworking"
desc = "MDX-packaged sample app."
ipa = "data/#{app}.ipa"


## env
log_path = "log/"
mdx = "dist/#{app}.mdx"

appc_base_url = "https://161.202.193.123:4443"

# pre-requisite: MDX Toolkit installed.
prep_tool_bin = "/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "data/citrix_2014.mobileprovision"



## user-interfacing tasks

# cloning: unzip ipa, rewrite info.plist with new bundle id, rezip ipa.
task :clone => [ :'ipa:unzip', :'ipa:rewrite_bid', :'ipa:zip' ]


# packaging: wrap with mdx, unzip mdx, rewrite policy, rezip mdx.
task :package => [ :'mdx:create', :'mdx:unzip', :'rewrite_policy', :'mdx:zip' ]




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


namespace :mdx do

	task :create do
		sh %(
			#{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_path}/#{app}-mdx.log" -logWriteLevel "4" -appName "#{app}" -appDesc "#{desc}"
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


	## experimental

	Rake::PackageTask.new("rake", "1.2.3") do |p|
		p.need_zip = true
		p.package_files.include("")
	end

end


namespace :app_controller do
	headers = %(
		-H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: #{appc_base_url}/ControlPoint/" -H "Origin: #{appc_base_url}" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36"
	).strip

	task :login do
		sh %(
			/usr/bin/curl #{appc_base_url}/ControlPoint/ #{headers} --compressed -k -I --cookie-jar data/cookies.txt -v
		)
		
		cookies_a = `cat data/cookies.txt`.each_line.map{|e| e.split("\t")}.map{|e| e[5..6]}.compact
		cookies_a << ['OCAJSESSIONID', '(null)']
		$cookies_as_headers = "Cookie: " + cookies_a.map{|k,v| "#{k}=#{v.strip}"}.join("; ")

		$csrf_token_header=`/usr/bin/curl #{appc_base_url}/ControlPoint/JavaScriptServlet -X POST #{headers} --compressed -k --cookie data/cookies.txt -H "FETCH-CSRF-TOKEN: 1"`.gsub(":", ": ")

		sh %(	
			/usr/bin/curl #{appc_base_url}/ControlPoint/rest/newlogin #{headers} --compressed -k --cookie data/cookies.txt -H "#{$csrf_token_header}" -H "Content-Type: application/json" --data "@mm2PackagingFactory/Resources/login.txt" -v
			
			echo "### login complete."
		)
	end

	task :create => :login do
	end

	task :update => :login do
		# /usr/bin/curl -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: https://161.202.193.123:4443/ControlPoint/" -H "Origin: https://161.202.193.123:4443" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36" -H "Cookie: JSESSIONID=E989363500CAA9BAF9F06706DE810DBA; ACNODEID=8226125278091195649; OCAJSESSIONID=(null)" -H "CG_CSRFTOKEN: VXLZ-27RA-293X-HEE4-WNU9-5YTF-AD4G-BUY9" --compressed -k "https://161.202.193.123:4443/ControlPoint/upload?CG_CSRFTOKEN=VXLZ-27RA-293X-HEE4-WNU9-5YTF-AD4G-BUY9" --form "data=@/Users/andy/Documents/src/mm2PackagingFactory/data/MVCNetworking.mdx;type=application/octet-stream" 

		# /usr/bin/curl -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: https://161.202.193.123:4443/ControlPoint/" -H "Origin: https://161.202.193.123:4443" -H "Content-Type: application/json;charset=UTF-8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36" -H "Cookie: JSESSIONID=E989363500CAA9BAF9F06706DE810DBA; ACNODEID=8226125278091195649; OCAJSESSIONID=(null)" -H "CG_CSRFTOKEN: VXLZ-27RA-293X-HEE4-WNU9-5YTF-AD4G-BUY9" --compressed -k "https://161.202.193.123:4443/ControlPoint/rest/mobileappmgmt/upgradepkg/MobileApp92" --data "MVCNetworking.mdx" 

		# /usr/bin/curl -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept: application/json,text/javascript,text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.8" -H "Connection: keep-alive" -H "X-Requested-With: CloudGateway AJAX" -H "Referer: https://161.202.193.123:4443/ControlPoint/" -H "Origin: https://161.202.193.123:4443" -H "Content-Type: application/json;charset=UTF-8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.76 Safari/537.36" -H "Cookie: JSESSIONID=E989363500CAA9BAF9F06706DE810DBA; ACNODEID=8226125278091195649; OCAJSESSIONID=(null)" -H "CG_CSRFTOKEN: VXLZ-27RA-293X-HEE4-WNU9-5YTF-AD4G-BUY9" --compressed -k "https://161.202.193.123:4443/ControlPoint/rest/mobileappmgmt/upgrade/MobileApp92" --data "@/Users/andy/Documents/src/mm2PackagingFactory/data/MVCNetworking.json" 

		# TODO get app id
		app_id = "MobileApp92"
	
		sh %(
			/usr/bin/curl #{appc_base_url}/ControlPoint/upload?CG_CSRFTOKEN=#{$csrf_token_header.gsub('CG_CSRFTOKEN: ', '')} #{headers} --compressed -k --cookie data/cookies.txt -H "#{$csrf_token_header}" --form "data=@#{mdx};type=application/octet-stream" -vvv

			/usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgradepkg/#{app_id} #{headers} --compressed -k --cookie data/cookies.txt  -H "#{$csrf_token_header}" --data "#{app}.mdx"

			/usr/bin/curl #{appc_base_url}/ControlPoint/rest/mobileappmgmt/upgrade/#{app_id} #{headers} --compressed -k --cookie data/cookies.txt -H "Content-Type: application/json" --data "data/#{app}.json"

		)

	end
end

