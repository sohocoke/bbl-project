require 'rake/packagetask'

## run-specific params
app = "MVCNetworking"
desc = "MDX-packaged sample app."
ipa = "mm2PackagingFactory/Resources/#{app}.ipa"


## env
log_path = "log/"
mdx = "dist/#{app}.mdx"

# pre-requisite: MDX Toolkit installed.
prep_tool_bin = "/Applications/Citrix/MDXToolkit/CGAppCLPrepTool"

# pre-requisite: enterprise cert installed.
cert = "iPhone Distribution: Credit Suisse AG"

# pre-requisite: enterprise provisioning profile.
profile = "mm2PackagingFactory/Resources/citrix_2014.mobileprovision"



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
		# 2014-07-29 10:51:20.343 mm2PackagingFactory[4770:303] will run task: (in /Users/andy/Library/Developer/Xcode/DerivedData/mm2PackagingFactory-ewivmycboqcyggcxxxfbodztwxcz/Build/Products/Debug) /Applications/Citrix/MDXToolkit/CGAppCLPrepTool "Wrap" -Cert "iPhone Distribution: Credit Suisse AG" -Profile "/Users/andy/Documents/src/mm2PackagingFactory/mm2PackagingFactory/Resources/citrix_2014.mobileprovision" -in "/Users/andy/Documents/src/mm2PackagingFactory/mm2PackagingFactory/Resources/MVCNetworking.ipa" -out "/Users/andy/Documents/src/mm2PackagingFactory/mm2PackagingFactory/Resources/MVCNetworking.mdx" -logFile "wrap-MVCNetworking.log" -logWriteLevel "4" -appName "MVCNetworking" -appDesc "test wrapping MVCNetworking" -maxPlatform "7.1" 

		sh %(
			#{prep_tool_bin} Wrap -Cert "#{cert}" -Profile "#{profile}" -in "#{ipa}" -out "#{mdx}" -logFile "#{log_path}/#{app}-mdx.log" -logWriteLevel "4" -appName "#{app}" -appDesc "#{desc}"
		)

	end

	task :unzip do
		sh %(
			unzip #{mdx} -d "mdx-unzipped"
		)
	end

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
	task :login do
	end

	task :create => :login do
	end

	task :update => :login do
	end
end

