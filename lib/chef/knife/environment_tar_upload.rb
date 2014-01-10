require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class EnvironmentTarUpload < Chef::Knife

      banner "knife environment tar upload tarPath [options]"
      category "environment tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        EnvironmentTarUpload.upload_environments tar_file
        
      end
      
      def self.upload_environments(tar_file)
        environment_from_file = Chef::Knife::EnvironmentFromFile.new
        
        tar_file.environments.each do |environment_path|
          environment_from_file.name_args = [environment_path]
          environment_from_file.run
        end
      end

    end
  end
end