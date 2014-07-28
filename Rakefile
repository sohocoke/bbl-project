require 'rake/packagetask'


mdx = "mm2PackagingFactory/Resources/MVCNetworking.mdx"


	end
namespace :mdx do

	# task wrap: PoC in PackagingFactory.


	task :unzip do
		sh %(
			unzip #{mdx} -d "mdx-unzipped"
		)
	end

	task :update_policy do
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

