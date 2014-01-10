require 'chef/knife'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require 'chef/tar_file'
require 'tmp_directory'

class Chef
  class Knife
    class CookbookTarUpload < Chef::Knife
      
      # This is the list of CookbookVersion's that are already uploaded to the chef-server
      @@current_cookbooks = nil
      
      banner "knife cookbook tar upload tarPath (options)"
      category "cookbook tar"
      
      # This method will be executed when you run this knife command.
      def run
        
        if @name_args.size != 1
          ui.info("Please specify a tarPath")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        CookbookTarUpload.upload_cookbooks tar_file
        
      end
      
      def self.upload_cookbooks(tar_file)
        # This is the list of cookbooks and their groupings, we upload all the cookbooks in a group at a time
        cookbook_upload_groups = Array.new
        
        cookbook_paths = tar_file.cookbooks
        
        cookbook_group_index = 0
        
        total_cookbooks = cookbook_paths.length
        
        # Since we now allow you to upload multiple versions of the same cookbook we have to be smart about how we upload the cookbooks
        # If we upload a cookbook without the proper dependency we will get errors
        
        # So the strategy is to categorize cookbooks into groups based on their dependencies and what has been uploaded
        # Then move the cookbooks to a tmp directory (renaming their directories if necessary) and upload each group in order
        
        while !cookbook_paths.empty?
          
          cookbook_upload_groups.push(Array.new)
          
          # An array of current cookbook names we are uploading. This is used to ensure we dont upload the same cookbook 
          # (different version) in the same group
          cookbookNamesToUpload = Array.new
          
          cookbook_paths.each do |cookbook_path|
            cookbookName = CookbookTarUpload.get_cookbook_name_from_path cookbook_path
            
            # Verify we aren't uploading another version of the cookbook in this group
            unless cookbookNamesToUpload.index(cookbookName)
              
              # Check the cookbook has no dependencies or its dependencies have been uploaded
              
              md = Chef::Cookbook::Metadata.new
              md.from_file File.join(cookbook_path, "metadata.rb")
              
              uploadable = true
              md.dependencies.each do |cookbook_dependency, version_constraint|
                  
                # Verify we have uploaded the specific cookbook / version
                unless CookbookTarUpload.is_dependency_uploaded? cookbook_dependency, version_constraint, cookbook_upload_groups
                  ui.error "Cookbook #{cookbookName} depends on cookbook '#{cookbook_dependency}' version '#{version_constraint}',"
                  ui.error "which is not currently being uploaded and cannot be found on the server."
                  uploadable = false
                  break
                end  
                  
              end
              
              if uploadable
                # Add the cookbook to the group
                cookbook_upload_groups[cookbook_group_index].push cookbook_path
                # Add the cookbook's name to our list
                cookbookNamesToUpload.push(cookbookName)
              end
            end
          end
          
          # If we still have cookbooks that need to find a group but we did not add any to this group
          # we have an error. This can be caused by a missing dependency or a circular dependency.
          if cookbookNamesToUpload.empty?
            raise "Unable to upload cookbooks"
          end
          
          # Remove the cookbooks we have added to this group
          cookbook_upload_groups[cookbook_group_index].each do |cookbook_path|
            cookbook_paths.delete cookbook_path
          end
          
          cookbook_group_index+=1
          
        end
        
        puts "#{total_cookbooks} cookbooks have been grouped into #{cookbook_upload_groups.length} groups"
        puts "Uploading cookbooks ..."
        
        # Upload all cookbooks one group at a time
        cookbook_upload_groups.each do |cookbookGroup|
          cookbookTmpPath = ::TmpDirectory.new("cookbooks").path
          
          # Move cookbooks to tmp directory and rename if necessary
          cookbookGroup.each do |cookbook_path|
            FileUtils.cp_r cookbook_path, File.join(cookbookTmpPath, CookbookTarUpload.get_cookbook_name_from_path(cookbook_path))
          end
          
          #Upload cookbook group
          cookbookUploader = Chef::Knife::CookbookUpload.new
          cookbookUploader.config[:cookbook_path] = cookbookTmpPath
          cookbookUploader.config[:all] = true
          cookbookUploader.run
        end
      end
      
      private 
      
      # Returns the name of the cookbook from its path which could include its version information
      # (i.e. /var/chef/cookbooks/myCookbook-1.0.0 would return myCookbook)      
      def self.get_cookbook_name_from_path path
        directory = File.basename(path)
        index = directory =~ /(-[\d]+.[\d]+\.[\d]+\z|-[\d]+\.[\d]+\z)/
        if index!=nil
          return directory[0, index]
        end
        directory
      end
      
      # Given a cookbook's dependency information, and the current cookbooks that will be uploaded, determine if 
      # we have uploaded a valid version of that cookbook
      def self.is_dependency_uploaded? cookbook_dependency, version_constraint, cookbook_upload_groups
        vc = Chef::VersionConstraint.new(version_constraint)
        
        cookbook_upload_groups.each do |cookbook_group|
          cookbook_group.each do |cookbook_path|
            if CookbookTarUpload.get_cookbook_name_from_path(cookbook_path)==cookbook_dependency
              # Get the version of the cookbook that is already in a group
              md = Chef::Cookbook::Metadata.new
              md.from_file File.join(cookbook_path, "metadata.rb")
              if vc.include? md.version
                return true
              end
            end
          end
        end
        
        # The dependency we are wanting is not part of an upload group so check if it already exists on the chef-server
        if CookbookTarUpload.current_cookbooks.has_key? cookbook_dependency
          CookbookTarUpload.current_cookbooks[cookbook_dependency].each do |cookbookVersions|
            CookbookTarUpload.current_cookbooks[cookbook_dependency]["versions"].each do |cookbookVersion|
              if vc.include? cookbookVersion["version"]
                return true
              end
            end
          end
        end
        
        false
      end
      
      def self.current_cookbooks
        unless @@current_cookbooks
          rest = Chef::REST.new(Chef::Config[:chef_server_url])
          @@current_cookbooks = rest.get_rest('cookbooks?num_versions=all')
        end
        @@current_cookbooks
      end
      
    end
  end
end
