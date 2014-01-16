require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/user'
require 'yajl'

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
        current_users = Chef::User.list.keys
        users_loader = Chef::Knife::Core::ObjectLoader.new(Chef::User, ui)
        
        tar_file.web_users.each do |web_user_path|
          
          unless users_loader.find_file("users", web_user_path).nil?
            user_hash = Yajl::Parser.parse(IO.read(web_user_path))
          end
          user = Chef::User.from_hash(user_hash)
          
           # Update existing users, otherwise save the new user
          if current_users.include? user.name
            user.update
          else
            user.save
          end
 
          ui.info("Updated User : #{user.name}")
        end
      end
      
      

    end
  end
end