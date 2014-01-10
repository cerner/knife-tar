require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/role'

class Chef
  class Knife
    class RoleTarDownload < Chef::Knife

      banner "knife role tar download tarPath [options]"
      category "role tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        RoleTarDownload.download_roles tar_file
        tar_file.save
        
      end
      
      def self.download_roles(tar_file)
        dir = tar_file.roles_path
        Chef::Role.list.each do |component_name, url|
          Chef::Log.info("Backing up role #{component_name}")
          component_obj = Chef::Role.load(component_name)
          File.open(File.join(dir, "#{component_name}.json"), "w") do |component_file|
            component_file.print(component_obj.to_json)
          end
        end
      end

    end
  end
end