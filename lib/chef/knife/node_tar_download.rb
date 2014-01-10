require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/node'

class Chef
  class Knife
    class NodeTarDownload < Chef::Knife

      banner "knife node tar download tarPath [options]"
      category "node tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        NodeTarDownload.download_nodes tar_file
        tar_file.save
        
      end
      
      def self.download_nodes(tar_file)
        dir = tar_file.nodes_path
        Chef::Node.list.each do |component_name, url|
          Chef::Log.info("Backing up node #{component_name}")
          component_obj = Chef::Node.load(component_name)
          File.open(File.join(dir, "#{component_name}.json"), "w") do |component_file|
            component_file.print(component_obj.to_json)
          end
        end
      end

    end
  end
end