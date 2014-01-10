# coding: UTF-8

require 'chef/knife'
require 'chef/role'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class RoleTarUpload < Chef::Knife

      banner "knife role tar upload TARPATH [options]"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args[0])
        RoleTarUpload.upload_roles tar_file
        
      end
      
      def self.upload_roles tar_file
        role_from_file = Chef::Knife::RoleFromFile.new 
        role_from_file.name_args = tar_file.roles
        role_from_file.config[:print_after] = true
        role_from_file.run
      end

    end
  end
end