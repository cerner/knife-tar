require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class ClientTarUpload < Chef::Knife

      banner "knife client tar upload tarPath [options]"
      category "client tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        ClientTarUpload.upload_clients tar_file
        
      end
      
      def self.upload_clients(tar_file)
        ui.confirm "This command will only work when running on chef-server or by updating the couchdb_url in your knife config to point to your couchdb instance. Are you sure you want to continue"
        
        client_loader = Chef::Knife::Core::ObjectLoader.new(Chef::ApiClient, ui)
        current_clients = Chef::ApiClient.list.keys
        
        tar_file.api_clients.each do |api_client_path|
          
          client = client_loader.load_from("clients", api_client_path)
          
          # In order to 'update' a client we have to remove it first, so if the client exists destroy it
          if current_clients.include? client.name
            ApiClient.load(client.name).destroy
          end
          
          client.save
          
          ui.info("Updated Client : #{client.name}")
          
        end
      end

    end
  end
end