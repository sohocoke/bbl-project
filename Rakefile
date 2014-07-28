require 'rake/packagetask'


ipa = "mm2PackagingFactory/Resources/MVCNetworking.ipa"
mdx = "mm2PackagingFactory/Resources/MVCNetworking.mdx"


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
		# TODO migrate PoC in PackagingFactory and integrate in workflow.
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

