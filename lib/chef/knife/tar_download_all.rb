require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class TarDownload < Chef::Knife

      banner "knife tar download tarPath [options]"
      category "tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        
        ClientTarDownload.download_clients tar_file
        CookbookTarDownload.download_cookbooks tar_file
        DataBagTarDownload.download_data_bags tar_file
        EnvironmentTarDownload.download_environments tar_file
        NodeTarDownload.download_nodes tar_file
        RoleTarDownload.download_roles tar_file
        UserTarDownload.download_users tar_file
        
        tar_file.save
        
      end

    end
  end
end