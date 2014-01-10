require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/api_client'

class Chef
  class Knife
    class ClientTarDownload < Chef::Knife

      banner "knife client tar download tarPath [options]"
      category "client tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        ClientTarDownload.download_clients tar_file
        tarFile.save
        
      end
      
      def self.download_clients(tar_file)
        dir = tar_file.api_clients_path
        Chef::ApiClient.list.each do |component_name, url|
          Chef::Log.info("Backing up client #{component_name}")
          component_obj = Chef::ApiClient.load(component_name)
          File.open(File.join(dir, "#{component_name}.json"), "w") do |component_file|
            component_file.print(component_obj.to_json)
          end
        end
      end

    end
  end
end