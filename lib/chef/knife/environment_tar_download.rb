require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/environment'

class Chef
  class Knife
    class EnvironmentTarDownload < Chef::Knife

      @@DEFAULT_ENVIRONMENT = "_default"

      banner "knife environment tar download tarPath [options]"
      category "environment tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        EnvironmentTarDownload.download_environments tar_file
        tar_file.save
        
      end
      
      def self.download_environments(tar_file)
        dir = tar_file.environments_path
        Chef::Environment.list.each do |component_name, url|
          if component_name != @@DEFAULT_ENVIRONMENT
            Chef::Log.info("Backing up environment #{component_name}")
            component_obj = Chef::Environment.load(component_name)
            File.open(File.join(dir, "#{component_name}.json"), "w") do |component_file|
              component_file.print(component_obj.to_json)
            end
          end
        end
      end

    end
  end
end