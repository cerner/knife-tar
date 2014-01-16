require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/user'

class Chef
  class Knife
    class UserTarDownload < Chef::Knife

      banner "knife user tar download tarPath [options]"
      category "user tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        UserTarDownload.download_users tar_file
        tar_file.save
        
      end
      
      def self.download_users(tar_file)
        dir = tar_file.web_users_path
        Chef::User.list.each do |component_name, url|
          Chef::Log.info("Backing up user #{component_name}")
          component_obj = Chef::User.load(component_name)
          File.open(File.join(dir, "#{component_name}.json"), "w") do |component_file|
            component_file.print(component_obj.to_json)
          end
        end
      end

    end
  end
end