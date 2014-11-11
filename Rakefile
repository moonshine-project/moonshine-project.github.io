require 'rake'

desc 'Preview the site with Jekyll'
task :preview do
  sh "jekyll serve --watch --drafts --baseurl ''"
end

desc 'Search site and print specific deprecation warnings'
task :check do 
  sh "jekyll doctor"
end

desc "Generate the site, serve locally and watch for changes"
task :watch do
  sh "jekyll serve --watch --baseurl ''"
end

Dir.glob('_tasks/*.rake').each do |r|
  load r
end
