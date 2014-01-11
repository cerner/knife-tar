# coding: UTF-8

task :default => [:build]

task :build  do
  puts "Building the gem"
  runCommand "gem build knife-tar.gemspec"
end

task :release => [:build] do
  deployGem
  release
end

def deployGem
  begin
    puts "Pushing the gem to rubygems.org"
    runCommand "gem push knife-tar*.gem"
  ensure
    system "rm -f knife-tar*.gem"
  end
end

def release
 
  rawVersion = `cat VERSION`.chomp
 
  #Tag the release
  puts "Tagging the release"
  runCommand "git tag -a #{rawVersion} -m 'Released #{rawVersion}'"
  runCommand "git push origin #{rawVersion}"
  
  # Update bump VERSION file
  versions = rawVersion.split "."
  versions[1] = versions[1].to_i + 1
  newVersion = versions.join "."
  
  puts "Changing version from #{rawVersion} to #{newVersion}"
  
  runCommand "echo '#{newVersion}' > VERSION"
  
  #Commit the updated VERSION file
  puts "Commiting the new VERSION file"
  runCommand "git add VERSION"
  runCommand "git commit -m 'Released #{rawVersions} and bumped version to #{newVersion}'"
  runCommand "git push origin master"
  
end

def runCommand command
  output = system command
  unless output
    # Removes changes to tracked files
    system "git reset --hard"
    
    # Removes any new un-tracked files
    system "git clean -f -d"
    
    raise "Command : #{command} failed"
  end
end
