# coding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'knife-tar'
  s.version     = File.read('VERSION').strip
  s.authors     = ["Bryan Baugher", "Aaron Blythe"]
  s.email       = 'Bryan.Baugher@Cerner.com'
  s.summary     = "A Chef knife plugin to install/upload chef components from a tar file or url"
  s.description = "This is a knife plugin for Chef which can install and upload chef components from a tar file or url"
  s.homepage    = 'http://github.com/Cerner/knife-tar'
  s.license     = 'Apache License, Version 2.0'
  s.files       = Dir['lib/**/*.rb', 'Gemfile', 'Rakefile', 'README.md']
  
  # Removes gem build warning
  s.rubyforge_project = "nowarning"
  
  s.add_dependency 'chef', '>= 0.10.0'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
end
