require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/webui_user'

class Chef
  class Knife
    class UserTarUpload < Chef::Knife

      banner "knife user tar upload tarPath [options]"
      category "user tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        UserTarUpload.upload_users tar_file
        
      end
      
      def self.upload_users(tar_file)
        current_users = Chef::WebUIUser.list.keys
        users_loader = Chef::Knife::Core::ObjectLoader.new(Chef::WebUIUser, ui)
        
        tar_file.web_users.each do |web_user_path|
          
          user = users_loader.load_from("users", web_user_path)
          
           # In order to 'update' a user we have to remove it first, so if the user exists destroy it
          if current_users.include? user.name
            ui.info("Deleting Chef User [#{user.name}] in order to update it")
            WebUIUser.load(user.name).destroy
          end
          
          user.save
          ui.info("Updated User : #{user.name}")
        end
      end
      
      

    end
  end
end