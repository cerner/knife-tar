# coding: UTF-8

task :default => [:build]

task :build  do
  build
end

task :release => [:build] do
  release
end

def build
  puts "Building the gem ..."
  runCommand "gem build knife-tar.gemspec"
  puts "Gem built!"
end

def deploy
  begin
    buildGem
    
    puts "Publishing the gem ..."
    runCommand "gem push knife-tar*.gem"
    puts "Gem published!"
  ensure
    system "rm -f knife-tar*.gem"
  end
end

def release
  
  # Publish the gem
  deploy
  
  # Get current version
  rawVersion = `cat VERSION`.chomp
 
  #Tag the release
  puts "Tagging the #{rawVersion} release ..."
  runCommand "git tag -a #{rawVersion} -m 'Released #{rawVersion}'"
  runCommand "git push origin #{rawVersion}"
  puts "Release tagged!"
  
  # Bump VERSION file
  versions = rawVersion.split "."
  versions[1] = versions[1].to_i + 1
  newVersion = versions.join "."
  
  puts "Updating version from #{rawVersion} to #{newVersion} ..."
  runCommand "echo '#{newVersion}' > VERSION"
  puts "Version updated!"
  
  #Commit the updated VERSION file
  puts "Commiting the new version ..."
  runCommand "git add VERSION"
  runCommand "git commit -m 'Released #{rawVersion} and bumped version to #{newVersion}'"
  runCommand "git push origin HEAD"
  puts "Version commited!"
end

def runCommand command
  output = `#{command}`
  unless $?.success?
    raise "Command : [#{command}] failed.\nOutput : \n#{output}"
  end
end
