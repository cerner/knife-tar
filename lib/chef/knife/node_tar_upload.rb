require 'chef/knife'
require 'chef/node'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class NodeTarUpload < Chef::Knife

      banner "knife node tar upload tarPath [options]"
      category "node tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        NodeTarUpload.upload_nodes tar_file

      end
      
      def self.upload_nodes(tar_file)
        node_from_file = Chef::Knife::NodeFromFile.new
        
        tar_file.nodes.each do |nodes_path|
          node_from_file.name_args = [nodes_path]
          node_from_file.run
        end
      end

    end
  end
end